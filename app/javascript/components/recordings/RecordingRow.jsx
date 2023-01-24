import {
  VideoCameraIcon, Square2StackIcon,
  EllipsisVerticalIcon,
  TrashIcon, PencilSquareIcon,
} from '@heroicons/react/24/outline';
import Form from 'react-bootstrap/Form';
import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button, Stack, Dropdown,
} from 'react-bootstrap';
import { toast } from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import Spinner from '../shared_components/utilities/Spinner';
import UpdateRecordingForm from './forms/UpdateRecordingForm';
import DeleteRecordingForm from './forms/DeleteRecordingForm';
import Modal from '../shared_components/modals/Modal';

// TODO: Amir - Refactor this.
export default function RecordingRow({
  recording, visibilityMutation: useVisibilityAPI, deleteMutation: useDeleteAPI,
}) {
  const { t } = useTranslation();

  function copyUrls() {
    const formatUrls = recording.formats.map((format) => format.url);
    navigator.clipboard.writeText(formatUrls);
    toast.success('Copied');
  }

  const visibilityAPI = useVisibilityAPI();
  const [isEditing, setIsEditing] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);

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
            <span className="small text-muted"> {recording.created_at} </span>
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
        {recording.formats.map((format) => (
          <Button
            onClick={() => window.open(format.url, '_blank')}
            className={`btn-sm rounded-pill me-1 mt-1 border-0 btn-format-${format.recording_type.toLowerCase()}`}
            key={format.id}
          >
            {format.recording_type}
          </Button>
        ))}
      </td>
      <td className="border-start-0">
        <Dropdown className="float-end cursor-pointer">
          <Dropdown.Toggle className="hi-s" as={EllipsisVerticalIcon} />
          <Dropdown.Menu>
            <Dropdown.Item onClick={() => copyUrls()}>
              <Square2StackIcon className="hi-s me-2" />
              { t('recording.copy_recording_urls') }
            </Dropdown.Item>
            <Modal
              modalButton={<Dropdown.Item><TrashIcon className="hi-s me-2" />{ t('delete') }</Dropdown.Item>}
              title={t('are_you_sure')}
              body={(
                <DeleteRecordingForm
                  mutation={useDeleteAPI}
                  recordId={recording.record_id}
                />
              )}
            />
          </Dropdown.Menu>
        </Dropdown>
      </td>
    </tr>
  );
}

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
    protectable: PropTypes.bool.isRequired,
    created_at: PropTypes.string.isRequired,
    map: PropTypes.func,
  }).isRequired,
  visibilityMutation: PropTypes.func.isRequired,
  deleteMutation: PropTypes.func.isRequired,
};
