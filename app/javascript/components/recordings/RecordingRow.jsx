import {
  VideoCameraIcon, TrashIcon, PencilSquareIcon, ClipboardDocumentIcon, EllipsisVerticalIcon,
} from '@heroicons/react/24/outline';
import Form from 'react-bootstrap/Form';
import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button, Stack, Dropdown,
} from 'react-bootstrap';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import { useAuth } from '../../contexts/auth/AuthProvider';
import Spinner from '../shared_components/utilities/Spinner';
import UpdateRecordingForm from './forms/UpdateRecordingForm';
import DeleteRecordingForm from './forms/DeleteRecordingForm';
import Modal from '../shared_components/modals/Modal';
import { localizeDateTimeString } from '../../helpers/DateTimeHelper';

// TODO: Amir - Refactor this.
export default function RecordingRow({
  recording, visibilityMutation: useVisibilityAPI, deleteMutation: useDeleteAPI, adminTable,
}) {
  const { t } = useTranslation();

  function copyUrls() {
    const formatUrls = recording.formats.map((format) => format.url);
    navigator.clipboard.writeText(formatUrls);
    toast.success(t('toast.success.recording.copied_urls'));
  }

  const visibilityAPI = useVisibilityAPI();
  const [isEditing, setIsEditing] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);
  const currentUser = useAuth();
  const localizedTime = localizeDateTimeString(recording?.created_at, currentUser?.language);
  const formats = recording.formats.sort(
    (a, b) => (a.recording_type.toLowerCase() > b.recording_type.toLowerCase() ? 1 : -1),
  );

  return (
    <tr key={recording.id} className="align-middle text-muted border border-2">
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
                    className="hi-s text-muted ms-1 mb-1"
                  />
                </>
                )
              }
              {
                isUpdating && <Spinner animation="grow" variant="brand" />
              }
            </strong>
            <span className="small text-muted"> {localizedTime} </span>
          </Stack>
        </Stack>
      </td>
      <td className="border-0"> { t('recording.length_in_minutes', { recording }) } </td>
      <td className="border-0"> {recording.participants} </td>
      <td className="border-0">
        {/* TODO: Refactor this. */}
        <Form.Select
          className="visibility-dropdown"
          onChange={(event) => {
            visibilityAPI.mutate({ visibility: event.target.value, id: recording.record_id });
          }}
          defaultValue={recording.visibility}
          disabled={visibilityAPI.isLoading}
        >
          <option value="Published">{ t('recording.published') }</option>
          <option value="Unpublished">{ t('recording.unpublished') }</option>
          {recording?.protectable === true
            && <option value="Protected">{ t('recording.protected') }</option>}
        </Form.Select>
      </td>
      <td className="border-0">
        {formats.map((format) => (
          <Button
            onClick={() => window.open(format.url, '_blank')}
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
                <Dropdown.Item onClick={() => copyUrls()}>
                  <ClipboardDocumentIcon className="hi-s me-2" />
                  { t('recording.copy_recording_urls') }
                </Dropdown.Item>
                <Modal
                  modalButton={<Dropdown.Item><TrashIcon className="hi-s me-2" />{ t('delete') }</Dropdown.Item>}
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
              <Button
                variant="icon"
                className="mt-1 me-3"
                onClick={() => copyUrls()}
              >
                <ClipboardDocumentIcon className="hi-s text-muted" />
              </Button>
              <Modal
                modalButton={<Dropdown.Item className="btn btn-icon"><TrashIcon className="hi-s me-2" /></Dropdown.Item>}
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
    created_at: PropTypes.string.isRequired,
    map: PropTypes.func,
  }).isRequired,
  visibilityMutation: PropTypes.func.isRequired,
  deleteMutation: PropTypes.func.isRequired,
  adminTable: PropTypes.bool,
};
