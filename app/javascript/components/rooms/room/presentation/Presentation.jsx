import React from 'react';
import {
  Card, Col, Row,
} from 'react-bootstrap';
import { TrashIcon, CloudUploadIcon, DocumentIcon } from '@heroicons/react/outline';
import { useParams } from 'react-router-dom';
import Modal from '../../../shared_components/modals/Modal';
import useUploadPresentation from '../../../../hooks/mutations/rooms/useUploadPresentation';
import useRoom from '../../../../hooks/queries/rooms/useRoom';
import DeletePresentationForm from './forms/DeletePresentationForm';
import FilesDragAndDrop from '../../../shared_components/utilities/FilesDragAndDrop';

export default function Presentation() {
  const { friendlyId } = useParams();
  const { data: room } = useRoom(friendlyId);
  const { onSubmit } = useUploadPresentation(friendlyId);

  const onDrop = (files) => {
    onSubmit(files[0]);
  };

  if (!room.presentation_name) {
    return (
      <div className="wide-background full-height-room">
        <FilesDragAndDrop
          onDrop={onDrop}
          numOfFiles={1}
          formats={['.doc', '.docx', '.pptx', '.txt', '.png', '.jpg', '.pdf']}
        >
          <Card className="border-0 shadow-sm mt-3 text-center">
            <label htmlFor="file" className="presentation-upload">
              <Card.Body className="py-5 text-secondary cursor-pointer">
                <div className="icon-circle rounded-circle d-block mx-auto mb-3">
                  <CloudUploadIcon className="hi-l text-brand d-block mx-auto pt-4" />
                </div>
                <input
                  id="file"
                  className="d-none"
                  type="file"
                  onChange={(e) => onSubmit(e.target.files[0])}
                  accept=".doc,.docx,.pptx,.txt,.png,.jpg,.pdf"
                />
                <Card.Title className="text-brand">
                  Click to Upload or drag and drop
                </Card.Title>
                <Card.Text>
                  Upload any office document or PDF file. Depending on the size of the
                  presentation, it may require additional time to upload before it can be used
                </Card.Text>
              </Card.Body>
            </label>
          </Card>
        </FilesDragAndDrop>
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
                <DocumentIcon className="hi-xl text-brand" />
              )}
            </Col>
            <Col>
              {room.presentation_name}
            </Col>
            <Col />
            <Col>
              <Modal
                modalButton={<TrashIcon className="cursor-pointer hi-s" />}
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
