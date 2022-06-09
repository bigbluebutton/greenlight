import React, { useState } from 'react';
import { Button, Card } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCloudArrowUp } from '@fortawesome/free-solid-svg-icons';
import { useParams } from 'react-router-dom';
import useUploadPresentation from '../../hooks/mutations/rooms/useUploadPresentation';
import useRoom from '../../hooks/queries/rooms/useRoom';

export default function Presentation() {
  const { friendlyId } = useParams();
  const [presentation, setPresentation] = useState();
  const { data: room } = useRoom(friendlyId);
  const { onSubmit } = useUploadPresentation(friendlyId);

  if (!room.presentation) {
    return (
      <div className="wide-background full-height-room">
        <Card className="border-0 shadow-sm mt-3 text-center">
          <Card.Body className="py-5">
            <div className="user-icon-circle rounded-circle d-block mx-auto mb-3">
              <FontAwesomeIcon icon={faCloudArrowUp} className="fa-4x text-primary d-block mx-auto pt-3" />
            </div>
            <Card.Title className="text-primary"> Click to upload or drag and drop </Card.Title>
            <Card.Text>
              Upload any office document or PDF file. Depending on the size of the
              presentation, it may require additional time to upload before it can be used
            </Card.Text>
            <input type="file" onChange={(e) => setPresentation(e.target.files[0])} accept="*" />
            <Button variant="primary" className="w-100 my-3 py-2" onClick={() => onSubmit(presentation)}>
              Upload Presentation
            </Button>
          </Card.Body>
        </Card>
      </div>
    );
  }
  return (
    <div className="wide-background full-height-room">
      <Card className="border-0 shadow-sm mt-3 text-center">
        <Card.Body className="py-5">
          {room.presentation}
        </Card.Body>
      </Card>
    </div>
  );
}
