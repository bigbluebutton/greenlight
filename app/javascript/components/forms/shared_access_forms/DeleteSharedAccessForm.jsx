/* eslint-disable react/jsx-props-no-spreading */

import React from 'react';
import { useForm } from 'react-hook-form';
import { Button, Form } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrashAlt } from '@fortawesome/free-regular-svg-icons';
import PropTypes from 'prop-types';
import { useParams } from 'react-router-dom';
import useDeleteSharedAccess from '../../../hooks/mutations/shared_accesses/useDeleteSharedAccess';

export default function DeleteSharedAccessForm({ userId }) {
  const { friendlyId } = useParams();
  const { register, handleSubmit } = useForm();
  const { onSubmit } = useDeleteSharedAccess(friendlyId);

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
