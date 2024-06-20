// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import React, { useRef, useEffect } from 'react';
import PropTypes from 'prop-types';
import { toast } from 'react-toastify';

export default function FilesDragAndDrop({
  onDrop, children, numOfFiles, formats,
}) {
  const drop = useRef(null);

  const handleDragOver = (e) => {
    e.preventDefault();
    e.stopPropagation();
  };

  const handleDrop = (e) => {
    e.preventDefault();
    e.stopPropagation();

    // this is required to convert FileList object to array
    const files = [...e.dataTransfer.files];

    // check number of files
    if (numOfFiles && numOfFiles < files.length) {
      toast.error('There was a problem completing that action. \n Please try again.');
      return;
    }

    // check file formats
    if (formats && files.some((file) => !formats.some((format) => file.name.toLowerCase().endsWith(format.toLowerCase())))) {
      toast.error(`Invalid file formats. \n Accepted file formats: ${formats.join(', ')}`);
      return;
    }

    if (files && files.length) {
      onDrop(files);
    }
  };

  const handleDragEnter = (e) => {
    e.preventDefault();
    e.stopPropagation();
  };

  const handleDragLeave = (e) => {
    e.preventDefault();
    e.stopPropagation();
  };

  useEffect(() => {
    drop.current.addEventListener('dragover', handleDragOver);
    drop.current.addEventListener('drop', handleDrop);
    drop.current.addEventListener('dragenter', handleDragEnter);
    drop.current.addEventListener('dragleave', handleDragLeave);
  }, []);

  return (
    <div
      className="FilesDragAndDrop__area"
      ref={drop}
    >
      {children}
    </div>
  );
}

FilesDragAndDrop.propTypes = {
  onDrop: PropTypes.func.isRequired,
  children: PropTypes.element.isRequired,
  numOfFiles: PropTypes.number.isRequired,
  formats: PropTypes.arrayOf(String).isRequired,
};
