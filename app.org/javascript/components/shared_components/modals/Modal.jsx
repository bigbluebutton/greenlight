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
