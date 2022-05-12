/* eslint-disable react/jsx-props-no-spreading */

import React, { useContext } from 'react';
import { useForm } from 'react-hook-form';
import { Button, Form } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrashAlt } from '@fortawesome/free-regular-svg-icons';
import PropTypes from 'prop-types';
import useDeleteSharedAccess from '../../../hooks/mutations/shared_accesses/useDeleteSharedAccess';
import RoomContext from '../../../contexts/roomContext';

export default function DeleteSharedAccessForm({ userId }) {
  const { register, handleSubmit } = useForm();
  const room = useContext(RoomContext);
  const { onSubmit } = useDeleteSharedAccess(room.id);

  return (
    <Form onSubmit={handleSubmit(onSubmit)} className="float-end pe-2">
      <input value={userId} type="hidden" {...register('user_id')} />
      <Button variant="font-awesome" type="submit">
        <FontAwesomeIcon icon={faTrashAlt} />
      </Button>
    </Form>
  );
}

DeleteSharedAccessForm.propTypes = {
  userId: PropTypes.number.isRequired,
};
