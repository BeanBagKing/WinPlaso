# -*- coding: utf-8 -*-
"""The VMDK image file-like object."""

import pyvmdk

from dfvfs.file_io import file_object_io
from dfvfs.lib import errors
from dfvfs.path import factory as path_spec_factory
from dfvfs.resolver import resolver


class VMDKFile(file_object_io.FileObjectIO):
  """File input/output (IO) object using pyvmdk."""

  def _OpenFileObject(self, path_spec):
    """Opens the file-like object defined by path specification.

    Args:
      path_spec (PathSpec): path specification.

    Returns:
      pyvmdk.handle: a file-like object.

    Raises:
      IOError: if the file-like object could not be opened.
      OSError: if the file-like object could not be opened.
      PathSpecError: if the path specification is incorrect.
    """
    if not path_spec.HasParent():
      raise errors.PathSpecError(
          'Unsupported path specification without parent.')

    parent_path_spec = path_spec.parent

    parent_location = getattr(parent_path_spec, 'location', None)
    if not parent_location:
      raise errors.PathSpecError(
          'Unsupported parent path specification without location.')

    # Note that we cannot use pyvmdk's open_extent_data_files_as_file_objects
    # function since it does not handle the file system abstraction dfVFS
    # provides.

    file_system = resolver.Resolver.OpenFileSystem(
        parent_path_spec, resolver_context=self._resolver_context)

    file_object = resolver.Resolver.OpenFileObject(
        parent_path_spec, resolver_context=self._resolver_context)

    vmdk_handle = pyvmdk.handle()
    vmdk_handle.open_file_object(file_object)

    parent_location_path_segments = file_system.SplitPath(parent_location)

    # On Windows, SplitPath can yield a drive prefix as a separate segment
    # (e.g. ["D:", "dir", "disk.vmdk"]). Some JoinPath implementations will
    # drop that drive prefix, yielding an invalid extent path like "\dir\s001.vmdk".
    # Preserve the drive prefix and re-apply it after JoinPath.
    drive_prefix = ''
    if parent_location_path_segments:
      first_segment = parent_location_path_segments[0]
      if (isinstance(first_segment, str) and len(first_segment) == 2 and
          first_segment[1] == ':'):
        drive_prefix = first_segment
        parent_location_path_segments = parent_location_path_segments[1:]

    # Build stable "parent directory" segments once, instead of mutating in-loop.
    # The last segment is the descriptor filename.
    parent_dir_segments = parent_location_path_segments[:-1]

    extent_data_files = []
    for extent_descriptor in iter(vmdk_handle.extent_descriptors):
      extent_data_filename = extent_descriptor.filename

      _, path_separator, filename = extent_data_filename.rpartition('/')
      if not path_separator:
        _, path_separator, filename = extent_data_filename.rpartition('\\')

      if not path_separator:
        filename = extent_data_filename

      extent_segments = list(parent_dir_segments)
      extent_segments.append(filename)
      extent_data_file_location = file_system.JoinPath(extent_segments)

      # Re-apply Windows drive prefix if it was split off above.
      if drive_prefix:
        extent_data_file_location = f'{drive_prefix}{extent_data_file_location}'

      # Note that we don't want to set the keyword arguments when not used
      # because the path specification base class will check for unused
      # keyword arguments and raise.
      kwargs = path_spec_factory.Factory.GetProperties(parent_path_spec)

      kwargs['location'] = extent_data_file_location
      if parent_path_spec.parent is not None:
        kwargs['parent'] = parent_path_spec.parent

      extent_data_file_path_spec = path_spec_factory.Factory.NewPathSpec(
          parent_path_spec.type_indicator, **kwargs)

      if not file_system.FileEntryExistsByPathSpec(extent_data_file_path_spec):
        break

      extent_data_files.append(extent_data_file_path_spec)

    if len(extent_data_files) != vmdk_handle.number_of_extents:
      raise IOError('Unable to locate all extent data files.')

    file_objects = []
    for extent_data_file_path_spec in extent_data_files:
      file_object = resolver.Resolver.OpenFileObject(
          extent_data_file_path_spec, resolver_context=self._resolver_context)
      file_objects.append(file_object)

    # TODO: add parent image support.
    vmdk_handle.open_extent_data_files_as_file_objects(file_objects)

    return vmdk_handle

  def get_size(self):
    """Retrieves the size of the file-like object.

    Returns:
      int: size of the file-like object data.

    Raises:
      IOError: if the file-like object has not been opened.
      OSError: if the file-like object has not been opened.
    """
    if not self._is_open:
      raise IOError('Not opened.')

    return self._file_object.get_media_size()
