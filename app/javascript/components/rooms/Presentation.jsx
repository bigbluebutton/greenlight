import React from 'react';
import { Card, Col, Row } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  faCloudArrowUp, faFileAlt, faTrashAlt,
} from '@fortawesome/free-solid-svg-icons';
import { faTrashAlt } from '@fortawesome/free-regular-svg-icons';
import Modal from '../shared/Modal';
import { useParams } from 'react-router-dom';
import Modal from '../shared/Modal';
import useUploadPresentation from '../../hooks/mutations/rooms/useUploadPresentation';
import useRoom from '../../hooks/queries/rooms/useRoom';
import DeletePresentationForm from '../forms/DeletePresentationForm';

export default function Presentation() {
  const { friendlyId } = useParams();
  const { data: room } = useRoom(friendlyId);
  const { onSubmit } = useUploadPresentation(friendlyId);

  if (!room.presentation_name) {
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
                  className="d-none"
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
          <Row className="align-middle align-items-center justify-content-center">
            <Col>
              {room.thumbnail ? (
                <img className="preview-image" src={room.thumbnail} alt="Presentation" />
              ) : (
                <FontAwesomeIcon icon={faFileAlt} className="text-primary" size="3x" />
              )}
            </Col>
            <Col>
              {room.presentation_name}
            </Col>
            <Col />
            <Col>
              <Modal
                modalButton={<FontAwesomeIcon className="delete-presentation" icon={faTrashAlt} size="lg" />}
                title="Are you sure?"
                body={<DeletePresentationForm />}
              />
            </Col>
          </Row>
        </Card.Body>
      </Card>
    </div>
  );
}
