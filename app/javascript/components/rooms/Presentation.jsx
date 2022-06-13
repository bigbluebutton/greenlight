import React from 'react';
import { Card } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCloudArrowUp } from '@fortawesome/free-solid-svg-icons';
import { useParams } from 'react-router-dom';
import useUploadPresentation from '../../hooks/mutations/rooms/useUploadPresentation';
import useRoom from '../../hooks/queries/rooms/useRoom';

export default function Presentation() {
  const { friendlyId } = useParams();
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
            <Card.Title className="text-primary">
              <label htmlFor="file" className="presentation-upload">Click to Upload
                <input
                  id="file"
                  style={{ display: 'none' }}
                  type="file"
                  onChange={(e) => onSubmit(e.target.files[0])}
                  accept=".doc,.docx,.pptx,.txt,.png,.jpg,.pdf"
                />
              </label>
            </Card.Title>
            <Card.Text>
              Upload any office document or PDF file. Depending on the size of the
              presentation, it may require additional time to upload before it can be used
            </Card.Text>
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
