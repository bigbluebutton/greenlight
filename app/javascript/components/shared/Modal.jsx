import React, { useState } from 'react';
import { Modal as BootstrapModal } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Modal({
  modalButton, title, body,
}) {
  const [show, setShow] = useState(false);

  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  const Body = React.cloneElement(body, { handleClose });
  const ModalButton = React.cloneElement(modalButton, { onClick: handleShow });

  return (
    <>
      {ModalButton}
      <BootstrapModal show={show} onHide={handleClose} centered contentClassName="border-0 shadow-sm">
        <BootstrapModal.Header className="d-block mx-auto border-0 pb-0">
          <BootstrapModal.Title>{title}</BootstrapModal.Title>
        </BootstrapModal.Header>
        <BootstrapModal.Body>{Body}</BootstrapModal.Body>
      </BootstrapModal>
    </>
  );
}

Modal.propTypes = {
  title: PropTypes.string.isRequired,
  modalButton: PropTypes.element.isRequired,
  body: PropTypes.node.isRequired,
};
