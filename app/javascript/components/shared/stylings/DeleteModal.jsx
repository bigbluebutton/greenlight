import React, { useState } from 'react';
import { Modal, Button } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function DeleteModal({ title, body, children }) {
  const [show, setShow] = useState(false);

  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  return (
    <>
      <Button variant="danger" onClick={handleShow}>
        Delete
      </Button>

      <Modal className="text-center" show={show} onHide={handleClose}>
        <Modal.Header className="border-0" closeButton />
        <Modal.Title>{title}</Modal.Title>
        <Modal.Body>{body}</Modal.Body>
        <Modal.Footer className="">
          <Button variant="secondary" onClick={handleClose}>
            Close
          </Button>
          { children }
        </Modal.Footer>
      </Modal>
    </>
  );
}

DeleteModal.propTypes = {
  title: PropTypes.string.isRequired,
  body: PropTypes.string.isRequired,
  children: PropTypes.node.isRequired,
};
