import React, { useRef, useEffect } from 'react';
import PropTypes from 'prop-types';

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
      console.log(`Only ${numOfFiles} file${numOfFiles !== 1 ? 's' : ''} can be uploaded at a time`);
      return;
    }

    // check file formats
    if (formats && files.some((file) => !formats.some((format) => file.name.toLowerCase().endsWith(format.toLowerCase())))) {
      console.log(`Only following file formats are acceptable: ${formats.join(', ')}`);
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
