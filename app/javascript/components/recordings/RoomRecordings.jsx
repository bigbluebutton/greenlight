import React from 'react';
import { Table, Card, Row } from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faVideo, faTrashCan } from '@fortawesome/free-solid-svg-icons';
import Modal from '../shared/Modal';
import Spinner from '../shared/stylings/Spinner';
import useRoomRecordings from '../../hooks/queries/recordings/useRoomRecordings';
import DeleteRecordingForm from '../forms/DeleteRecordingForm';

export default function RoomRecordings() {
  const { friendlyId } = useParams();
  const { isLoading, data: recordings } = useRoomRecordings(friendlyId);

  if (isLoading) return <Spinner />;

  return (
    <div className="pt-3 wide-background full-height-room">
      <Row>
        <Card className="border-0 shadow-sm">
          <Table hover className="text-secondary mb-0">
            <thead>
              <tr>
                <th>Name</th>
                <th>Length</th>
                <th>Users</th>
                <th>Visibility</th>
                <th>Formats</th>
              </tr>
            </thead>
            <tbody>
              {recordings.map((recording) => (
                <tr key={recording.id} className="recordings align-middle">
                  <td className="text-dark">
                    <div> <FontAwesomeIcon className="mx-2 mt-4" icon={faVideo} size="2xl" /> <strong> {recording.name} </strong> </div>
                    <div className="small text-muted ms-5 ps-2"> {recording.created_at} </div>
                  </td>
                  <td> {recording.length}min </td>
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
              ))}
            </tbody>
          </Table>
        </Card>
      </Row>
    </div>
  );
}
