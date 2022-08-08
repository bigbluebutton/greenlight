import {
  VideoCameraIcon, DuplicateIcon,
  DotsVerticalIcon,
  TrashIcon,
} from '@heroicons/react/outline';
import Form from 'react-bootstrap/Form';
import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Button, Stack, Dropdown,
} from 'react-bootstrap';
import { toast } from 'react-hot-toast';
import Spinner from './stylings/Spinner';
import UpdateRecordingForm from '../forms/UpdateRecordingForm';
import DeleteRecordingForm from '../forms/DeleteRecordingForm';
import Modal from './Modal';

// TODO: Refactor this.
export default function RecordingRow({
  recording, visibilityMutation: useVisibilityAPI, updateMutation: useUpdateAPI, deleteMutation: useDeleteAPI,
}) {
  function copyUrls() {
    const formatUrls = recording.formats.map((format) => format.url);
    navigator.clipboard.writeText(formatUrls);
    toast.success('Copied');
  }

  const visibilityAPI = useVisibilityAPI();
  const [isEditing, setIsEditing] = useState(false);
  const [isUpdating, setIsUpdating] = useState(false);

  return (
    <tr key={recording.id} className="align-middle">
      <td className="border-end-0 text-dark">
        <Stack direction="horizontal" className="py-2">
          <div className="recording-icon-circle rounded-circle me-3 d-flex align-items-center justify-content-center">
            <VideoCameraIcon className="hi-s text-brand" />
          </div>
          <Stack>
            <strong role="button" aria-hidden="true" onClick={() => !isUpdating && setIsEditing(true)} onBlur={() => setIsEditing(false)}>
              <UpdateRecordingForm
                mutation={useUpdateAPI}
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
                isUpdating && <Spinner animation="grow" variant="brand" />
              }
            </strong>

            <span className="small text-muted"> {recording.created_at} </span>
          </Stack>
        </Stack>
      </td>
      <td className="border-0"> {recording.length}min</td>
      <td className="border-0"> {recording.users} </td>
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
          <option value="Published">Published</option>
          <option value="Unpublished">Unpublished</option>
          {recording?.protectable === true
            && <option value="Protected">Protected</option>}
        </Form.Select>
      </td>
      <td className="border-0">
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
      <td className="border-start-0">
        <Dropdown className="cursor-pointer">
          <Dropdown.Toggle className="hi-s" as={DotsVerticalIcon} />
          <Dropdown.Menu>
            <Dropdown.Item onClick={() => copyUrls()}><DuplicateIcon className="hi-s" /> Copy Recording Url(s)</Dropdown.Item>
            <Modal
              modalButton={<Dropdown.Item><TrashIcon className="hi-s" /> Delete</Dropdown.Item>}
              title="Are you sure?"
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
    id: PropTypes.number.isRequired,
    record_id: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    length: PropTypes.number.isRequired,
    users: PropTypes.number.isRequired,
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
  updateMutation: PropTypes.func.isRequired,
  deleteMutation: PropTypes.func.isRequired,
};
