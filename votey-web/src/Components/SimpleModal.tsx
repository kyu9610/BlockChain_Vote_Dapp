import React, { useState } from "react";
import { makeStyles, Theme, createStyles } from "@material-ui/core/styles";
import Modal from "@material-ui/core/Modal";
import { colors } from "../modules/settings";

interface Props {
  isModalOpen: boolean;
  onClickModal(): void;
  title: string;
  description: string;
}

const rand = () => {
  return Math.round(Math.random() * 20) - 10;
}

const getModalStyle = () => {
  const top = 50 + rand();
  const left = 50 + rand();

  return {
    top: `${top}%`,
    left: `${left}%`,
    transform: `translate(-${top}%, -${left}%)`,
  };
}

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    paper: {
      position: "absolute",
      width: 400,
      backgroundColor: colors.voteyBlack,
      color: colors.voteyWhite,
      border: "2px solid #000",
      boxShadow: theme.shadows[5],
      padding: theme.spacing(2, 4, 3),
    },
  })
);

const SimpleModal: React.FC<Props> = ({
  isModalOpen,
  onClickModal,
  title,
  description,
}) => {
  const classes = useStyles();
  const [modalStyle] = React.useState(getModalStyle);

  const body = (
    <div style={modalStyle} className={classes.paper}>
      <h2 id="simple-modal-title"> {title} </h2>
      <p id="simple-modal-description"> {description} </p>
    </div>
  );

  return (
    <div>
      <Modal
        open={isModalOpen}
        onClick={onClickModal}
        aria-labelledby="simple-modal-title"
        aria-describedby="simple-modal-description"
      >
        {body}
      </Modal>
    </div>
  );
};

export default SimpleModal;
