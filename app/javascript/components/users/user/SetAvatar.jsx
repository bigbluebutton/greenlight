import React, { useRef, useState } from 'react';
import { Button, Stack, Modal } from 'react-bootstrap';
import PropTypes from 'prop-types';
import AvatarEditor from 'react-avatar-editor';
import DeleteAvatarForm from './forms/DeleteAvatarForm';
import Avatar from './Avatar';
import useCreateAvatar from '../../../hooks/mutations/users/useCreateAvatar';

export default function SetAvatar({ user }) {
  // Use styled button instead of the default HTML input upload button
  const avatarUpload = useRef(null);
  const handleClick = () => avatarUpload?.current.click();

  // Editor Modal
  const [show, setShow] = useState(false);
  const handleClose = () => setShow(false);
  const handleShow = () => setShow(true);

  const [avatar, setAvatar] = useState();
  const handleNewAvatar = (e) => {
    handleShow();
    setAvatar(e.target.files[0]);
  };

  const createAvatar = useCreateAvatar(user);

  const editor = useRef(null);
  const handleSave = () => {
    if (editor) {
      createAvatar.mutate(editor.current.getImageScaledToCanvas());
      handleClose();
    }
  };

  return (
    <>
      <Stack direction="vertical" className="float-end">
        <Avatar avatar={user?.avatar} radius={150} />
        <Stack direction="horizontal" gap={2} className="mt-2">
          <input
            id="avatarUpload"
            ref={avatarUpload}
            className="d-none"
            type="file"
            onChange={handleNewAvatar}
            accept=".png,.jpg,.svg"
          />
          <DeleteAvatarForm user={user} />
          <Button variant="brand" onClick={handleClick}>Upload</Button>
        </Stack>
      </Stack>

      <Modal show={show} onHide={handleClose} centered contentClassName="border-0 shadow-sm">
        <Modal.Header closeButton>
          <Modal.Title>Crop your Avatar</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <div className="text-center">
            <AvatarEditor
              ref={editor}
              image={avatar}
              width={250}
              height={250}
              border={50}
              borderRadius={250}
              color={[255, 255, 255, 0.6]} // RGBA
              scale={1.2}
            />
          </div>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="brand-backward" onClick={handleClose}>
            Close
          </Button>
          <Button variant="brand" onClick={handleSave}>
            Save Changes
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  );
}

// TODO - samuel: user object can be destructured (only id and avatar is needed here)
SetAvatar.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.string.isRequired,
    avatar: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string.isRequired,
    provider: PropTypes.string.isRequired,
    role: PropTypes.shape({
      id: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      color: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
};
