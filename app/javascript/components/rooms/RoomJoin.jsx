import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import {
  Button, Col, Row, Stack,
} from 'react-bootstrap';
import FormLogo from '../forms/FormLogo';
import useRoom from '../../hooks/queries/rooms/useRoom';
import Spinner from '../shared/stylings/Spinner';
import useRoomStatus from '../../hooks/queries/rooms/useRoomStatus';
import Avatar from '../users/Avatar';

export default function RoomJoin() {
  const { friendlyId } = useParams();

  const [name, setName] = useState('');
  const [accessCode, setAccessCode] = useState('');

  const { isLoading, data: room } = useRoom(friendlyId, true);
  const { isSuccess: isSuccessStatus, isError: isErrorStatus, refetch: refetchStatus } = useRoomStatus(friendlyId, name, accessCode);

  if (isLoading) return <Spinner />;

  return (
    <div className="wide-background">
      <div className="vertical-center">
        <FormLogo />
        <Card className="col-md-6 mx-auto p-0 border-0 shadow-sm">
          <Card.Body className="p-4">
            <Row>
              <Col>
                <Stack>
                  <p className="text-muted mb-0">You have been invited to join</p>
                  <h1>
                    { room.name }
                  </h1>
                </Stack>
              </Col>
              <Col className="col-4">
                <Stack>
                  <Avatar className="d-block m-auto" avatar={room.owner_avatar} radius={100} />
                  <span className="float-end text-center mt-2">{room.owner_name}</span>
                </Stack>
              </Col>
            </Row>
          </Card.Body>
          <Card.Footer className="p-4 bg-white">
            { (isSuccessStatus) ? (
              <div className="mt-3">
                <Row>
                  <Col className="col-10">
                    <p className="mb-1">The meeting hasn&apos;t started yet</p>
                    <p className="mb-0 text-muted">You will automatically join when the meeting starts</p>
                  </Col>
                  <Col className="col-2">
                    <Spinner className="float-end" />
                  </Col>
                </Row>
              </div>
            ) : (
              <>
                <label htmlFor="join-name" className="small text-muted d-block"> Name
                  <input
                    type="text"
                    id="join-name"
                    placeholder="Enter your name"
                    className="form-control"
                    onChange={(event) => setName(event.target.value)}
                  />
                </label>
                { room?.viewer_access_code
                  && (
                    <div className="mt-2">
                      <label htmlFor="access-code" className="small text-muted d-block"> Access Code
                        <input
                          type="text"
                          id="access-code"
                          placeholder="Enter the access code"
                          className="form-control"
                          onChange={(event) => setAccessCode(event.target.value)}
                        />
                      </label>
                      {
                        (isErrorStatus)
                        && (
                          <p className="text-danger"> Wrong access code. </p>
                        )
                      }
                    </div>
                  )}
                { (!(room?.viewer_access_code) && room?.moderator_access_code)
                  && (
                    <div className="mt-2">
                      <label htmlFor="access-code" className="small text-muted d-block"> Moderator Access Code (optional)
                        <input
                          type="text"
                          id="access-code"
                          placeholder="Enter the access code"
                          className="form-control"
                          onChange={(event) => setAccessCode(event.target.value)}
                        />
                      </label>
                      {
                        (isErrorStatus)
                        && (
                          <p className="text-danger"> Wrong access code. </p>
                        )
                      }
                    </div>
                  )}
                <Button className="mt-3 d-block float-end" onClick={refetchStatus}>Join Session</Button>
              </>
            )}
          </Card.Footer>
        </Card>
      </div>
    </div>
  );
}
