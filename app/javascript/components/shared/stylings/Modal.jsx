import React, { useState } from 'react';
import { Modal as BootstrapModal } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Modal({
  modalButton, title, body, footer,
}) {
  const [show, setShow] = useState(false);

  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  const Footer = React.cloneElement(footer, { handleClose });
  const ModalButton = React.cloneElement(modalButton, { onClick: handleShow });

  return (
    <>
      {ModalButton}
      <BootstrapModal className="text-center" show={show} onHide={handleClose}>
        <BootstrapModal.Header className="border-0" closeButton />
        <BootstrapModal.Title>{title}</BootstrapModal.Title>
        <BootstrapModal.Body>{body}</BootstrapModal.Body>
        <BootstrapModal.Footer>
          {Footer}
        </BootstrapModal.Footer>
      </BootstrapModal>
    </>
  );
}

Modal.propTypes = {
  title: PropTypes.string.isRequired,
  footer: PropTypes.element.isRequired,
  modalButton: PropTypes.element.isRequired,
  body: PropTypes.element.isRequired,
};
