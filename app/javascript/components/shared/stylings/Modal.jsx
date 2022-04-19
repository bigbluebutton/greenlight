import React, { useState } from 'react';
import { Button, Modal as BootstrapModal } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Modal({ title, body, children }) {
  const [show, setShow] = useState(false);

  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  return (
    <>
      <Button variant="danger" onClick={handleShow}>
        Delete
      </Button>

      <BootstrapModal className="text-center" show={show} onHide={handleClose}>
        <BootstrapModal.Header className="border-0" closeButton />
        <BootstrapModal.Title>{title}</BootstrapModal.Title>
        <BootstrapModal.Body>{body}</BootstrapModal.Body>
        <BootstrapModal.Footer className="">
          <Button variant="secondary" onClick={handleClose}>
            Close
          </Button>
          { children }
        </BootstrapModal.Footer>
      </BootstrapModal>
    </>
  );
}

Modal.propTypes = {
  title: PropTypes.string.isRequired,
  body: PropTypes.string.isRequired,
  children: PropTypes.node.isRequired,
};
