import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrashAlt, faVideo } from '@fortawesome/free-solid-svg-icons';
import React from 'react';
import PropTypes from 'prop-types';
import { Button, Stack, Table } from 'react-bootstrap';
import Modal from '../shared/Modal';
import DeleteRecordingForm from '../forms/DeleteRecordingForm';

export default function RecordingsList({ recordings }) {
  return (
    <Table hover className="text-secondary mb-0 recordings-list">
      <thead>
        <tr className="text-muted small">
          <th className="fw-normal">Name</th>
          <th className="fw-normal">Length</th>
          <th className="fw-normal">Users</th>
          <th className="fw-normal">Visibility</th>
          <th className="fw-normal">Formats</th>
          <th aria-label="options" />
        </tr>
      </thead>
      <tbody className="border-top-0">
        {recordings?.length
          ? (
            recordings?.map((recording) => (
              <tr key={recording.id} className="align-middle">
                <td className="text-dark">
                  <Stack direction="horizontal" className="py-2">
                    <div className="recording-icon-circle rounded-circle me-3 d-flex align-items-center justify-content-center">
                      <FontAwesomeIcon icon={faVideo} className="text-primary" />
                    </div>
                    <Stack>
                      <strong> {recording.name} </strong>
                      <span className="small text-muted"> {recording.created_at} </span>
                    </Stack>
                  </Stack>
                </td>
                <td> {recording.length}min</td>
                <td> {recording.users} </td>
                <td> {recording.visibility} </td>
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
                    modalButton={<FontAwesomeIcon icon={faTrashAlt} />}
                    title="Are you sure?"
                    body={<DeleteRecordingForm recordId={recording.record_id} />}
                  />
                </td>
              </tr>
            ))
          )
          : (
            <tr>
              <td className="fw-bold">
                No recordings found!
              </td>
            </tr>
          )}
      </tbody>
    </Table>
  );
}

RecordingsList.propTypes = {
  recordings: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    length: PropTypes.number.isRequired,
    users: PropTypes.number.isRequired,
    visibility: PropTypes.string.isRequired,
    created_at: PropTypes.string.isRequired,
    map: PropTypes.func.isRequired,
  })).isRequired,
};
