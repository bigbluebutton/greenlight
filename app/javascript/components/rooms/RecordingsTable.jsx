import React from 'react';
import { Table, Card } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faVideo } from '@fortawesome/free-solid-svg-icons';
import Spinner from '../shared/stylings/Spinner';
import useRecordings from '../../hooks/queries/recordings/useRecordings';

export default function RecordingsTable() {
  const { isLoading, data: recordings } = useRecordings();
  if (isLoading) return <Spinner />;

  return (
    <Row className="wide-background">
      <Card>
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
              </tr>
            ))}
          </tbody>
        </Table>
      </Card>
    </Row>
  );
}
