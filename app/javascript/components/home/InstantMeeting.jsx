import React from 'react';
import Image from 'react-bootstrap/Image';
import { Col, Row } from 'react-bootstrap';
import InstantMeetingForm from './InstantMeetingForm';

export default function InstantMeeting() {
  return (
    <div id="instant-meeting">
      <Row>



        <Col colSpan={6}>
            <div className="mt-5">
                <h3> BLINDSIDE NETWORKS </h3>
                <h1> Start & join meetings now!</h1>
                <p> No account necessary </p>
                <InstantMeetingForm />
            </div>
        </Col>



        <Col colSpan={6}>
          <Image src="https://images.pexels.com/photos/4144923/pexels-photo-4144923.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1" />
        </Col>
      </Row>
    </div>
  );
}
