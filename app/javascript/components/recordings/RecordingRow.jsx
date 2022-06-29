import { TrashIcon, VideoCameraIcon } from '@heroicons/react/outline';
import Form from 'react-bootstrap/Form';
import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Button, Stack } from 'react-bootstrap';
import Modal from '../shared/Modal';
import DeleteRecordingForm from '../forms/DeleteRecordingForm';
import usePublishRecording from '../../hooks/mutations/recordings/usePublishRecording';
import UpdateRecordingForm from '../forms/UpdateRecordingForm';
import Spinner from '../shared/stylings/Spinner';

export default function RecordingRow({ recording }) {
  const { handlePublishRecording } = usePublishRecording();
  const [isEditing, setIsEditing] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);

  return (
    <tr key={recording.id} className="align-middle">
      <td className="text-dark">
        <Stack direction="horizontal" className="py-2">
          <div className="recording-icon-circle rounded-circle me-3 d-flex align-items-center justify-content-center">
            <VideoCameraIcon className="hi-s text-primary" />
          </div>
          <Stack>
            <strong role="button" aria-hidden="true" onClick={() => !isUpdating && setIsEditing(true)} onBlur={() => setIsEditing(false)}>
              <UpdateRecordingForm
                recordId={recording.record_id}
                name={recording.name}
                hidden={!isEditing || isUpdating}
                setIsUpdating={setIsUpdating}
                noLabel
              />
              {
                !isEditing && recording.name
              }
              {
                isUpdating && <Spinner animation="grow" variant="primary" />
              }
            </strong>

            <span className="small text-muted"> {recording.created_at} </span>
          </Stack>
        </Stack>
      </td>
      <td> {recording.length}min</td>
      <td> {recording.users} </td>
      <td>
        {/* TODO: Refactor this. */}
        <Form.Select
          className="visibility-dropdown"
          onChange={(event) => {
            handlePublishRecording({ publish: event.target.value, record_id: recording.record_id });
          }}
          defaultValue={recording.visibility === 'Published'}
        >
          <option value="true">Published</option>
          <option value="false">Unpublished</option>
        </Form.Select>
      </td>
      <td>
        {recording.formats.map((format) => (
          <Button
            onClick={() => window.open(format.url, '_blank')}
            className={`btn-sm rounded-pill me-1 border-0 btn-format-${format.recording_type.toLowerCase()}`}
            key={format.id}
          >
            {format.recording_type}
          </Button>
        ))}
      </td>
      <td>
        <Modal
          modalButton={<TrashIcon className="hi-s" />}
          title="Are you sure?"
          body={<DeleteRecordingForm recordId={recording.record_id} />}
        />
      </td>
    </tr>
  );
}

RecordingRow.propTypes = {
  recording: PropTypes.shape({
    id: PropTypes.number.isRequired,
    record_id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    length: PropTypes.number.isRequired,
    users: PropTypes.number.isRequired,
    formats: PropTypes.PropTypes.arrayOf(PropTypes.shape({
      id: PropTypes.number.isRequired,
      url: PropTypes.string.isRequired,
      recording_type: PropTypes.string.isRequired,
    })),
    visibility: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
    map: PropTypes.func,
  }).isRequired,
};
