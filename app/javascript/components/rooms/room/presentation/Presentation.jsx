import React from 'react';
import {
  Card, Col, Row,
} from 'react-bootstrap';
import { TrashIcon, CloudArrowUpIcon, DocumentIcon } from '@heroicons/react/24/outline';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Modal from '../../../shared_components/modals/Modal';
import useUploadPresentation from '../../../../hooks/mutations/rooms/useUploadPresentation';
import useRoom from '../../../../hooks/queries/rooms/useRoom';
import DeletePresentationForm from './forms/DeletePresentationForm';
import FilesDragAndDrop from '../../../shared_components/utilities/FilesDragAndDrop';

export default function Presentation() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const { data: room } = useRoom(friendlyId);
  const { onSubmit } = useUploadPresentation(friendlyId);

  const onDrop = (files) => {
    onSubmit(files[0]);
  };

  if (!room.presentation_name) {
    return (
      <FilesDragAndDrop
        onDrop={onDrop}
        numOfFiles={1}
        formats={['.doc', '.docx', '.ppt', '.pptx', '.pdf', '.xls', '.xlsx', '.txt',
          '.rtf', '.odt', '.ods', '.odp', '.odg', '.odc', '.odi', '.jpg', '.jpeg', '.png']}
      >
        <div className="pt-3">
          <Card className="border-0 card-shadow text-center">
            <label htmlFor="file" className="presentation-upload">
              <Card.Body className="py-5 text-secondary cursor-pointer">
                <div className="icon-circle rounded-circle d-block mx-auto mb-3">
                  <CloudArrowUpIcon className="hi-l text-brand d-block mx-auto pt-4" />
                </div>
                <input
                  id="file"
                  className="d-none"
                  type="file"
                  onChange={(e) => onSubmit(e.target.files[0])}
                  accept=".doc,.docx,.pptx,.txt,.png,.jpg,.pdf"
                />
                <Card.Title className="text-brand">
                  { t('room.presentation.click_to_upload')}
                  <span className="fs-5 fw-normal text-muted">
                    { t('room.presentation.drag_and_drop')}
                  </span>
                </Card.Title>
                <Card.Text>
                  { t('room.presentation.upload_description') }
                </Card.Text>
              </Card.Body>
            </label>
          </Card>
        </div>
      </FilesDragAndDrop>
    );
  }
  return (
    <div className="pt-3">
      <Card className="border-0 card-shadow mt-3 text-center">
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
                body={<DeletePresentationForm />}
              />
            </Col>
          </Row>
        </Card.Body>
      </Card>
    </div>
  );
}
