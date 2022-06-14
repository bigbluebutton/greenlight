import React, { useState } from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import {
  Button, Col, Row,
} from 'react-bootstrap';
import FormLogo from '../forms/FormLogo';
import useRoom from '../../hooks/queries/rooms/useRoom';
import useRoomJoin from '../../hooks/queries/rooms/useRoomJoin';
import Spinner from '../shared/stylings/Spinner';
import useRoomStatus from '../../hooks/queries/rooms/useRoomStatus';
import Avatar from '../users/Avatar';

function waitOrJoin(refetchJoin, refetchStatus) {
  refetchStatus();
  refetchJoin();
}

export default function RoomJoin() {
  const { friendlyId } = useParams();

  const [name, setName] = useState('');
  const [accessCode, setAccessCode] = useState('');

  const { isLoading, data: room } = useRoom(friendlyId, true);
  const { isSuccess: isSuccessJoin, isError: isErrorJoin, refetch: refetchJoin } = useRoomJoin(friendlyId, name, accessCode);
  const { isSuccess: isSuccessStatus, isError: isErrorStatus, refetch: refetchStatus } = useRoomStatus(friendlyId, name, accessCode);

  if (isLoading) return <Spinner />;

  return (
    <div className="wide-background">
      <div className="vertical-center">
        <FormLogo />
        <Card className="col-md-6 mx-auto p-0 border-0 shadow-sm">
          <Card.Body className="p-4">
            <Col>
              <p className="text-muted mb-1">You have been invited to join</p>
              <h1 className="pb-2">
                { room.name }
              </h1>
            </Col>
            <Col className="ms-auto col-4">
              <Avatar className="float-end" avatar={room.owner.avatar} radius={100} />
              <p className="float-end">{room.owner.name}</p>
            </Col>
          </Card.Body>
          <Card.Footer className="p-4 bg-white">
            { (isSuccessStatus || isSuccessJoin) ? (
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
                { room?.viewer_access_code
                  && (
                    <div className="mb-2">
                      <p><strong> Please enter the 6-characters <i>access code</i> provided by the host. </strong></p>
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
                        (isErrorJoin || isErrorStatus)
                        && (
                          <p className="text-danger"> Wrong access code. </p>
                        )
                      }
                    </div>
                  )}
                <label htmlFor="join-name" className="small text-muted d-block"> Name
                  <input
                    type="text"
                    id="join-name"
                    placeholder="Enter your name"
                    className="form-control"
                    onChange={(event) => setName(event.target.value)}
                  />
                </label>
                <Button className="mt-3 d-block float-end" onClick={() => waitOrJoin(refetchJoin, refetchStatus)}>Join Session</Button>
              </>
            )}
          </Card.Footer>
        </Card>
      </div>
    </div>
  );
}
