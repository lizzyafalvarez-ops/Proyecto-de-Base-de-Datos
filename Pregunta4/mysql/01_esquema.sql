-- Pregunta 4.a: modelo relacional para conversaciones internas.

DROP TABLE IF EXISTS ComentarioConversacion;
DROP TABLE IF EXISTS Conversacion;

CREATE TABLE Conversacion (
    IDConv INT NOT NULL AUTO_INCREMENT,
    IDPub INT NOT NULL,
    Titulo VARCHAR(200),
    Estado VARCHAR(20) NOT NULL DEFAULT 'activa',
    PRIMARY KEY (IDConv),
    FOREIGN KEY fk_conv_publicacion (IDPub)
        REFERENCES Publicacion(IDPub)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_conv_estado
        CHECK (Estado IN ('activa', 'cerrada'))
);

CREATE TABLE ComentarioConversacion (
    IDComentario INT NOT NULL AUTO_INCREMENT,
    IDConv INT NOT NULL,
    IDU INT NOT NULL,
    IDComentarioPadre INT,
    Texto VARCHAR(400) NOT NULL,
    Fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (IDComentario),
    FOREIGN KEY fk_comentario_conversacion (IDConv)
        REFERENCES Conversacion(IDConv)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY fk_comentario_usuario (IDU)
        REFERENCES Usuario(IDU)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY fk_comentario_padre (IDComentarioPadre)
        REFERENCES ComentarioConversacion(IDComentario)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_conv_publicacion ON Conversacion(IDPub);
CREATE INDEX idx_comentario_conversacion ON ComentarioConversacion(IDConv);
CREATE INDEX idx_comentario_padre ON ComentarioConversacion(IDComentarioPadre);
