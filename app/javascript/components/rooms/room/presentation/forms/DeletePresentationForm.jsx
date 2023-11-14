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

import React from 'react';
import { useForm } from 'react-hook-form';
import {
  Button, Stack,
} from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import PropTypes from 'prop-types';
import { useTranslation } from 'react-i18next';
import { ExclamationTriangleIcon } from '@heroicons/react/24/outline';
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
      <Stack direction="horizontal" className="mb-3">
        <ExclamationTriangleIcon className="text-danger hi-xl" />
        <Stack direction="vertical" className="ps-3">
          <h3> { t('room.presentation.delete_presentation') } </h3>
          <p className="mb-0"> { t('room.presentation.are_you_sure_delete_presentation') } </p>
          <p className="mt-0"><strong> { t('action_permanent') } </strong></p>
        </Stack>
      </Stack>
      <Form methods={methods} onSubmit={deletePresentation.mutate}>
        <Stack direction="horizontal" gap={1} className="float-end">
          <Button variant="neutral" onClick={handleClose}>
            {t('close')}
          </Button>
          <Button variant="danger" type="submit" disabled={deletePresentation.isLoading}>
            { deletePresentation.isLoading && <Spinner className="me-2" /> }
            { t('delete') }
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
