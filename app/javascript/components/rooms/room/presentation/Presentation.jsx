// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
import { PRESENTATION_MAX_FILE_COEFF, PRESENTATION_SUPPORTED_EXTENSIONS } from '../../../../helpers/FileValidationHelper';

export default function Presentation() {
  const { t } = useTranslation();
  const { friendlyId } = useParams();
  const { data: room } = useRoom(friendlyId);
  const { onSubmit } = useUploadPresentation(friendlyId);

  const onDrop = (files) => {
    onSubmit(files[0]);
  };

  if (!room?.presentation_name) {
    return (
      <FilesDragAndDrop
        onDrop={onDrop}
        numOfFiles={1}
        formats={PRESENTATION_SUPPORTED_EXTENSIONS}
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
                  { t('room.presentation.upload_description', { size: `${PRESENTATION_MAX_FILE_COEFF} MB` }) }
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
