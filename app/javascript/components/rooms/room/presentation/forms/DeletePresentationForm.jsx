import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import Form from '../../../../shared_components/forms/Form';
import Spinner from '../../../../shared_components/utilities/Spinner';
import useDeletePresentation from '../../../../../hooks/mutations/rooms/useDeletePresentation';

export default function DeletePresentationForm({ handleClose }) {
  const { t } = useTranslation();
  const methods = useForm();
  const { friendlyId } = useParams();
  const deletePresentation = useDeletePresentation(friendlyId);
  return (
    <>
      <p className="text-center"> { t('room.presentation.are_you_sure_delete_presentation') }</p>
      <Form methods={methods} onSubmit={deletePresentation.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="close" onClick={handleClose}>
            { t('close') }
          </Button>
          <Button variant="danger" type="submit" disabled={deletePresentation.isLoading}>
            { t('delete') }
            { deletePresentation.isLoading && <Spinner /> }
          </Button>
        </Stack>
      </Form>
    </>
  );
}

DeletePresentationForm.propTypes = {
  handleClose: PropTypes.func,
};

DeletePresentationForm.defaultProps = {
  handleClose: () => {},
};
