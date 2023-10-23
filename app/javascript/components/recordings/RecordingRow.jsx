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

import {
  VideoCameraIcon, TrashIcon, PencilSquareIcon, ClipboardDocumentIcon, EllipsisVerticalIcon,
} from '@heroicons/react/24/outline';
import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button, Stack, Dropdown,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../contexts/auth/AuthProvider';
import Spinner from '../shared_components/utilities/Spinner';
import UpdateRecordingForm from './forms/UpdateRecordingForm';
import DeleteRecordingForm from './forms/DeleteRecordingForm';
import Modal from '../shared_components/modals/Modal';
import { localizeDateTimeString } from '../../helpers/DateTimeHelper';
import useRedirectRecordingUrl from '../../hooks/mutations/recordings/useRedirectRecordingUrl';
import useCopyRecordingUrl from '../../hooks/mutations/recordings/useCopyRecordingUrl';
import SimpleSelect from '../shared_components/utilities/SimpleSelect';

// TODO: Amir - Refactor this.
export default function RecordingRow({
  recording, visibilityMutation: useVisibilityAPI, deleteMutation: useDeleteAPI, adminTable,
}) {
  const { t } = useTranslation();

  const visibilityAPI = useVisibilityAPI();
  const [isEditing, setIsEditing] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);
  const [display, setDisplay] = useState('invisible');

  const currentUser = useAuth();
  const redirectRecordingUrl = useRedirectRecordingUrl();
  const copyRecordingUrl = useCopyRecordingUrl();

  const localizedTime = localizeDateTimeString(recording?.recorded_at, currentUser?.language);
  const formats = recording.formats.sort(
    (a, b) => (a.recording_type.toLowerCase() > b.recording_type.toLowerCase() ? 1 : -1),
  );

  return (
    <tr
      key={recording.id}
      className="align-middle text-muted border border-2"
      onMouseEnter={() => setDisplay('visible')}
      onMouseLeave={() => setDisplay('invisible')}
    >
      <td className="border-end-0 text-dark">
        <Stack direction="horizontal" className="py-2">
          <div className="recording-icon-circle rounded-circle me-3 d-flex justify-content-center">
            <VideoCameraIcon className="hi-s text-brand" />
          </div>
          <Stack>
            <strong>
              {/* TODO: Samuel - add an x button or something to the edit name form */}
              <UpdateRecordingForm
                recordId={recording.record_id}
                name={recording.name}
                hidden={!isEditing || isUpdating}
                setIsUpdating={setIsUpdating}
                setIsEditing={setIsEditing}
              />
              {
                !isEditing
                && (
                <>
                  { recording.name }
                  <PencilSquareIcon
                    role="button"
                    aria-hidden="true"
                    onClick={() => !isUpdating && setIsEditing(true)}
                    onBlur={() => setIsEditing(false)}
                    className={`hi-s text-muted ms-1 mb-1 ${display}`}
                  />
                </>
                )
              }
              {
                isUpdating && <Spinner animation="grow" variant="brand" />
              }
            </strong>
            <span className="small text-muted"> {localizedTime} </span>
            {adminTable && <span className="small text-muted fw-bold"> {recording?.user_name} </span>}
          </Stack>
        </Stack>
      </td>
      <td className="border-0"> {t('recording.length_in_minutes', { recording })} </td>
      <td className="border-0"> {recording.participants} </td>
      <td className="border-0">
        <SimpleSelect
          defaultValue={recording.visibility}
        >
          <Dropdown.Item
            key="Public/Protected"
            value="Public/Protected"
            onClick={() => visibilityAPI.mutate({ visibility: 'Public/Protected', id: recording.record_id })}
          >
            {t('recording.public_protected')}
          </Dropdown.Item>
          <Dropdown.Item
            key="Public"
            value="Public"
            onClick={() => visibilityAPI.mutate({ visibility: 'Public', id: recording.record_id })}
          >
            {t('recording.public')}
          </Dropdown.Item>
          <Dropdown.Item
            key="Protected"
            value="Protected"
            onClick={() => visibilityAPI.mutate({ visibility: 'Protected', id: recording.record_id })}
          >
            {t('recording.protected')}
          </Dropdown.Item>
          <Dropdown.Item
            key="Published"
            value="Published"
            onClick={() => visibilityAPI.mutate({ visibility: 'Published', id: recording.record_id })}
          >
            {t('recording.published')}
          </Dropdown.Item>
          <Dropdown.Item
            key="Unpublished"
            value="Unpublished"
            onClick={() => visibilityAPI.mutate({ visibility: 'Unpublished', id: recording.record_id })}
          >
            {t('recording.unpublished')}
          </Dropdown.Item>
        </SimpleSelect>
      </td>
      <td className="border-0">
        {recording?.visibility !== 'Unpublished' && formats.map((format) => (
          <Button
            onClick={() => redirectRecordingUrl.mutate({ record_id: recording.record_id, format: format.recording_type })}
            className={`btn-sm rounded-pill me-1 mt-1 border-0 btn-format-${format.recording_type.toLowerCase()}`}
            key={`${format.recording_type}-${format.url}`}
          >
            {format.recording_type}
          </Button>
        ))}
      </td>
      <td className="border-start-0">
        {adminTable
          ? (
            <Dropdown className="float-end cursor-pointer">
              <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />
              <Dropdown.Menu>
                <Dropdown.Item onClick={() => copyRecordingUrl.mutate({ record_id: recording.record_id })}>
                  <ClipboardDocumentIcon className="hi-s me-2" />
                  {t('recording.copy_recording_urls')}
                </Dropdown.Item>
                <Modal
                  modalButton={<Dropdown.Item><TrashIcon className="hi-s me-2" />{t('delete')}</Dropdown.Item>}
                  body={(
                    <DeleteRecordingForm
                      mutation={useDeleteAPI}
                      recordId={recording.record_id}
                    />
                  )}
                />
              </Dropdown.Menu>
            </Dropdown>
          )
          : (
            <Stack direction="horizontal" className="float-end recordings-icons">
              { recording?.visibility !== 'Unpublished' && (
                <Button
                  variant="icon"
                  className="mt-1 me-3"
                  title={t('recording.copy_recording_urls')}
                  onClick={() => copyRecordingUrl.mutate({ record_id: recording.record_id })}
                >
                  <ClipboardDocumentIcon className="hi-s text-muted" />
                </Button>
              )}
              <Modal
                modalButton={<Dropdown.Item className="btn btn-icon"><TrashIcon className="hi-s me-2" title={t('delete')} /></Dropdown.Item>}
                body={(
                  <DeleteRecordingForm
                    mutation={useDeleteAPI}
                    recordId={recording.record_id}
                  />
                )}
              />
            </Stack>
          )}
      </td>
    </tr>
  );
}

RecordingRow.defaultProps = {
  adminTable: false,
};

RecordingRow.propTypes = {
  recording: PropTypes.shape({
    id: PropTypes.string.isRequired,
    record_id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    length: PropTypes.number.isRequired,
    participants: PropTypes.number.isRequired,
    formats: PropTypes.arrayOf(PropTypes.shape({
      url: PropTypes.string.isRequired,
      recording_type: PropTypes.string.isRequired,
    })),
    visibility: PropTypes.string.isRequired,
    protectable: PropTypes.bool,
    recorded_at: PropTypes.string.isRequired,
    map: PropTypes.func,
    user_name: PropTypes.string,
  }).isRequired,
  visibilityMutation: PropTypes.func.isRequired,
  deleteMutation: PropTypes.func.isRequired,
  adminTable: PropTypes.bool,
};
