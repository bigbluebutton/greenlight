import React, { useState } from 'react';
import { Modal as BootstrapModal } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Modal({
  modalButton, title, body, size, id,
}) {
  const [show, setShow] = useState(false);

  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  const Body = React.cloneElement(body, { handleClose });
  const ModalButton = React.cloneElement(modalButton, { onClick: handleShow });

  return (
    <>
      {ModalButton}
      <BootstrapModal show={show} onHide={handleClose} centered size={size} id={id} contentClassName="border-0 card-shadow">
        <BootstrapModal.Header className="border-0 pb-0">
          <BootstrapModal.Title>{title}</BootstrapModal.Title>
        </BootstrapModal.Header>
        <BootstrapModal.Body>{Body}</BootstrapModal.Body>
      </BootstrapModal>
    </>
  );
}

Modal.propTypes = {
  title: PropTypes.string,
  modalButton: PropTypes.element.isRequired,
  body: PropTypes.node.isRequired,
  size: PropTypes.string,
  id: PropTypes.string,
};

Modal.defaultProps = {
  id: '',
  size: '',
  title: '',
};
