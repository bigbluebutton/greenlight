import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrashCan, faVideo } from '@fortawesome/free-solid-svg-icons';
import React from 'react';
import PropTypes from 'prop-types';
import { Table } from 'react-bootstrap';
import Modal from '../shared/Modal';
import DeleteRecordingForm from '../forms/DeleteRecordingForm';

export default function RecordingsList({ recordings }) {
  return (
    <Table hover className="text-secondary mb-0">
      <thead>
        <tr className="text-muted small">
          <th>Name</th>
          <th>Length</th>
          <th>Users</th>
          <th>Visibility</th>
          <th>Formats</th>
        </tr>
      </thead>
      <tbody className="border-top-0">
        {recordings?.length
          ? (
            recordings?.map((recording) => (
              <tr key={recording.id} className="recordings align-middle">
                <td className="text-dark">
                  <div><FontAwesomeIcon className="mx-2 mt-4" icon={faVideo} size="2xl" />
                    <strong> {recording.name} </strong>
                  </div>
                  <div className="small text-muted ms-5 ps-2"> {recording.created_at} </div>
                </td>
                <td> {recording.length}min</td>
                <td> {recording.users} </td>
                <td> {recording.visibility} </td>
                <td>
                  {recording.formats.map((format) => (
                    <div key={format.id}> {format.recording_type} </div>
                  ))}
                </td>
                <td>
                  <Modal
                    modalButton={<FontAwesomeIcon className="" icon={faTrashCan} size="lg" />}
                    title="Are you sure?"
                    body={<DeleteRecordingForm recordId={recording.id} />}
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
