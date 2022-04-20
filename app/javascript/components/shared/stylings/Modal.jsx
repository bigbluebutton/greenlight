import React, { useState } from 'react';
import { Button, Modal as BootstrapModal } from 'react-bootstrap';
import PropTypes from 'prop-types';

export default function Modal({
  buttonName, variant, title, body, children,
}) {
  const [show, setShow] = useState(false);

  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  const clonedChildren = React.Children.map(children, (child) => React.cloneElement(child, { handleClose }));

  return (
    <>
      <Button variant={variant} onClick={handleShow}>
        { buttonName }
      </Button>

      <BootstrapModal className="text-center" show={show} onHide={handleClose}>
        <BootstrapModal.Header className="border-0" closeButton />
        <BootstrapModal.Title>{title}</BootstrapModal.Title>
        <BootstrapModal.Body>{body}</BootstrapModal.Body>
        <BootstrapModal.Footer>
          { clonedChildren }
        </BootstrapModal.Footer>
      </BootstrapModal>
    </>
  );
}

Modal.propTypes = {
  buttonName: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  variant: PropTypes.string.isRequired,
  body: PropTypes.string.isRequired,
  children: PropTypes.node.isRequired,
};
