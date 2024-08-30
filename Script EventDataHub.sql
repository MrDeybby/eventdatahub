CREATE DATABASE EventDataHub;

Use EventDataHub;


CREATE TABLE Ciudades (
    CiudadID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(20) UNIQUE NOT NULL
);



CREATE TABLE Ubicaciones (
    UbicacionID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(30),
    Direccion TEXT NOT NULL,
    CiudadID INT NOT NULL,
    Capacidad INT,
    PrecioAlquiler DECIMAL(10,2),
    FOREIGN KEY (CiudadID) REFERENCES Ciudades(CiudadID)
);

CREATE INDEX INDXCiudadID on Ubicaciones(CiudadID);
CREATE INDEX INDXCapacidad on Ubicaciones(Capacidad);
CREATE INDEX INDXPrecioAlquiler on Ubicaciones(PrecioAlquiler);

CREATE TABLE Eventos (
    EventoID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(25) NOT NULL,
    Descripcion TEXT,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    UbicacionID INT NOT NULL,
    Estado ENUM('Activo', 'Cancelado', 'SoldOut', 'Finalizado', 'Pospuesto') NOT NULL,
    FOREIGN KEY (UbicacionID) REFERENCES Ubicaciones(UbicacionID)
);

CREATE INDEX INDXEventoID on Eventos(EventoID);
CREATE INDEX INDXFechaEvento on Eventos(Fecha);
CREATE INDEX INDXEstadoEvento on Eventos(Estado);

CREATE TABLE Boletas (
    BoletaID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(15) NOT NULL
);

CREATE TABLE BoletasEvento (
	BoletaEventoID INT AUTO_INCREMENT PRIMARY KEY,
    BoletaID INT NOT NULL,
    EventoID INT NOT NULL,
    Precio DECIMAL(10,2) NOT NULL,
    CantidadDisponible INT NOT NULL,
    FOREIGN KEY (BoletaID) REFERENCES Boletas(BoletaID),
    FOREIGN KEY (EventoID) REFERENCES Eventos(EventoID)
);

CREATE INDEX INDXEventoIDBE on BoletasEvento(EventoID);

CREATE TABLE Entradas (
    EntradaID INT AUTO_INCREMENT PRIMARY KEY,
    BoletaEventoID INT NOT NULL,
    Estado ENUM('Activa', 'Utilizada') NOT NULL,
    Codigo INT,
    FOREIGN KEY (BoletaEventoID) REFERENCES BoletasEvento(BoletaEventoID)
);

ALTER TABLE Entradas
MODIFY COLUMN Codigo BIGINT;

CREATE TABLE Organizadores (
    OrganizadorID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(25) NOT NULL,
    Email VARCHAR(30) NOT NULL,
    Teléfono VARCHAR(10) NOT NULL
);

CREATE INDEX INDXOrganizador on Organizadores(Nombre);

CREATE TABLE EventoOrganizador (
    EventoID INT NOT NULL,
    OrganizadorID INT NOT NULL,
    Inversion DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (EventoID, OrganizadorID),
    FOREIGN KEY (EventoID) REFERENCES Eventos(EventoID),
    FOREIGN KEY (OrganizadorID) REFERENCES Organizadores(OrganizadorID)
);

CREATE INDEX INDXEventoOrganizador on EventoOrganizador(EventoID);

CREATE TABLE Participantes (
    ParticipanteID INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(25) NOT NULL,
    Email VARCHAR(30) NOT NULL,
    Teléfono VARCHAR(10) NOT NULL,
    Tipo ENUM('Artista', 'Conferencista', 'Presentador', 'Sonido', 'Bailarines', 'Seguridad', 'DJ', 'Productora', 'Otro') NOT NULL
);

CREATE INDEX INDXTipoDeParticipante on Participantes(Tipo);

CREATE TABLE Contrataciones (
    EventoID INT NOT NULL,
    ParticipanteID INT NOT NULL,
    Descripcion TEXT NOT NULL,
    Precio DECIMAL(10,2),
    PRIMARY KEY (EventoID, ParticipanteID),
    FOREIGN KEY (EventoID) REFERENCES Eventos(EventoID),
    FOREIGN KEY (ParticipanteID) REFERENCES Participantes(ParticipanteID)
);


CREATE INDEX INDXContrataciones on Contrataciones(EventoID);


-- Triger para que se genere el codigo de las entradas
DELIMITER //

CREATE TRIGGER Codigo
BEFORE INSERT ON Entradas
FOR EACH ROW
BEGIN
    DECLARE IdEvento INT;
    DECLARE IdEntrada INT;
    DECLARE IdBoleta INT;

    -- Obtener EventoID usando BoletaEventoID
    SELECT EventoID INTO IdEvento
    FROM BoletasEvento
    WHERE BoletaEventoID = NEW.BoletaEventoID;

    -- Obtener el próximo ID de la entrada
    SET IdEntrada = (SELECT AUTO_INCREMENT
                     FROM INFORMATION_SCHEMA.TABLES
                     WHERE TABLE_SCHEMA = DATABASE()
                     AND TABLE_NAME = 'Entradas');

    -- Generar el código en el formato: IdEvento + Fecha actual (YYYYMMDD) + IdEntrada + IdBoleta
    SET NEW.Codigo = CONCAT(
        LPAD(IdEvento, 2, '0'),
        DATE_FORMAT(CURDATE(), '%Y%m%d'),
        LPAD(IdEntrada, 2, '0'),
        LPAD(NEW.BoletaEventoID, 1, '0')
    );
END//

DELIMITER ;




/*Trigger para que cantidadDiponible vaya reducciendo*/
DELIMITER //

CREATE TRIGGER ReduceCantidadDisponible
AFTER INSERT ON Entradas
FOR EACH ROW
BEGIN
    UPDATE BoletasEvento
    SET CantidadDisponible = CantidadDisponible - 1 WHERE BoletaEventoID = NEW.BoletaEventoID;
END;
//

DELIMITER ;

SHOW TRIGGERS LIKE 'Entradas';




INSERT INTO Ciudades (Nombre) VALUES
('Puerto Plata'),
('Santo Domingo'),
('Santiago'),
('Samaná'),
('La vega');

INSERT INTO Ubicaciones (Nombre, Direccion, CiudadID, Capacidad, PrecioAlquiler) VALUES
('Anfiteatro Puerto Plata', 'Malecón de Puerto Plata', 1, 4000, 150000),
('Ocean World Adventure Park', 'Calle Principal #3, Cofresi', 1, 1000, 100000),
('Teatro Nacional Eduardo Brito', 'Av. Máximo Gómez', 2, 1600, 500000),
('Hard Rock Live Santo Domingo', 'Blue Mall, Av. Winston Churchill', 2, 1000, 300000),
('Palacio de los Deportes', 'Av. 27 de Febrero', 2, 8337, 800000),
('Gran Arena del Cibao', 'Calle Independencia', 3, 8768, 700000),
('Centro León', 'Av. 27 de Febrero No. 146', 3, 500, 150000),
('Bahía Marina & Residences', 'Carretera Sánchez-Samaná Km 5', 4, 300, 50000),
('Parque Armando Bermúdez', 'Jarabacoa', 5, 500, 25000);

INSERT INTO Ubicaciones (Nombre, Direccion, CiudadID, Capacidad, PrecioAlquiler) VALUES
('Anfiteatro Luitio Marti', ' Av. Blvd. del Faro, Santo Domingo Este 11604', 2, 4500, 300000);

INSERT INTO Eventos (Nombre, Descripcion, Fecha, Hora, UbicacionID, Estado) VALUES
('Stand Viejos + Liondy', '¡Al otro dia no se trabaja!', '2024-07-01', '21:30:00', 19, 'Finalizado'),
('Festival Presidente', 'Un festival que reúne a los mejores artistas de música latina.', '2024-09-15', '18:00:00', 12, 'Activo'),
('Most Wanted Tour 2024', ' Nadie sabe lo que va a pasar mañana. No lo dejes escapar, porque quizás no lo vuelvas a ver.', '2024-10-05', '20:00:00', 14, 'Activo'),
('Festival del Merengue', 'Una noche dedicada al merengue con artistas nacionales.', '2024-08-17', '17:00:00', 18, 'Activo'),
('Yiyo Sarante', '¡No te pierdas la mejor fiesta del año con Yiyo Sarante!', '2024-11-10', '19:30:00', 15, 'Activo'),
('Vuelve la escuelota', 'La comedia mas esperada de todos los tiempos', '2024-08-30', '18:30:00', 16, 'Activo'),
 ('Fuego de Calle', 'Los artistas urbanos más candentes en un solo escenario', '2024-10-15', '19:00:00', 14, 'Activo'),
('Flow Quisqueyano', 'Para sentir el ritmo del barrio', '2024-12-01', '18:00:00', 14, 'Activo'),
('Dale Dembow', 'Una noche inolvidable con los reyes del dembow', '2024-08-18', '22:00:00', 11, 'Activo'),
('Luis Fonsi "25 Años Tour"', '', '2024-11-23', '20:30:00', 12, 'Activo');

INSERT INTO Boletas (Nombre) VALUES
('General'),
('Special Guest'),
('V.I.P'),
('PREMIUM');

INSERT INTO BoletasEvento (BoletaID, EventoID, Precio, CantidadDisponible) VALUES
(1, 1, 2500, 30),
(2, 1, 3000, 100),
(3, 1, 3500, 500),
(1, 2, 600, 600),
(2, 2, 1000, 500),
(3, 2, 1200, 500),
(1, 3, 7000, 4000),
(2, 3, 9000, 3000),
(3, 3, 12000, 1000),
(4, 3, 15000, 337),
(1, 4, 2000, 350),
(2, 4, 3000, 150),
(1, 5, 3500, 3768),
(2, 5, 5000, 3000),
(3, 5, 6500, 1500),
(4, 5, 8000, 500);

INSERT INTO Organizadores (Nombre, Email, Teléfono) VALUES
('Cesar Suarez JR', 'cesarsjr@gmail.com', '8091234567'),
('Ramirez Peralta', 'peraltar@outlook.com', '8492345678'),
('Carlos Rodríguez', 'carlos.rodriguez@gmail.com', '8293456789'),
('Big Show Pro', 'info@bigshowpro.com', '8094567890'),
('Luis Fernández', 'luis.fernandez@gmail.com', '8495678901'),
('Sofía López', 'sofia.lopez@outlook.com', '8296789012'),
('Javier Ramírez', 'javier.ramirez@gmail.com', '8097890123'),
('Brugal', 'info@brugal.com', '8498901234'),
('Cervecería Nacional', 'contacto@cerveceria.com', '8299012345'),
('Distribuidora La Nacional', 'ventas@lanacional.com', '8090123456');

INSERT INTO EventoOrganizador (EventoID, OrganizadorID, Inversion) VALUES
(1, 7, 300000),
(1, 2, 450000),
(1, 4, 55000),
(2, 1, 780000),
(2, 4, 600000),
(2, 6, 350000),
(2, 3, 350000),
(3, 6, 6500000),
(3, 7, 4500000),
(3, 8, 4000000),
(4, 9, 500000),
(4, 10, 600000),
(4, 1, 400000),
(5, 2, 700000),
(5, 3, 600000),
(5, 4, 300000),
(6, 5, 800000),
(6, 6, 400000),
(6, 7, 300000),
(7, 8, 750000),
(7, 9, 450000),
(7, 10, 300000),
(8, 1, 700000),
(8, 2, 500000),
(8, 3, 300000);

INSERT INTO EventoOrganizador (EventoID, OrganizadorID, Inversion) VALUES
(9, 4, 650000),
(9, 5, 450000),
(9, 6, 400000),
(10, 7, 5000000),
(10, 8, 5000000),
(10, 9, 3000000);

INSERT INTO Participantes (Nombre, Email, Teléfono, Tipo) VALUES
('Rubby Perez', 'info@rubbyperez .com', '8091234567', 'Artista'),
('Sergio Vargas', 'vargarsergio@gmail.com', '8091234567', 'Artista'),
('Juan Luis Guerra', 'juanluisguerra@gmail.com', '8091234567', 'Artista'),
('Miriam Cruz', 'info@miriamcruz.com', '8091112233', 'Artista'),
('Héctor Acosta', 'info@hectoracosta.com', '8092223344', 'Artista'),
('Mozart La Para', 'mozartlapara@infomlp.com', '8093334455', 'Artista'),
 ('Yiyo Sarante', 'info@yiyosarante.com', '8098889900', 'Artista'),
('Chiquito Team Band', 'chiquitoteamband@info.com', '8099990011', 'Artista'),
('SoundPro', 'info@soundpro.com', '8495678901', 'Sonido'),
('AudioTech', 'contacto@audiotech.com', '8296789012', 'Sonido'),
 ('VisualArts', 'info@visualarts.com', '8097890123', 'Productora'),
('LiveStream Inc.', 'support@livestream.com', '8498901234', 'Productora'),
 ('Aquiles Correa', 'correa.aquiles@gmail.com', '8299012345', 'Presentador'),
('Ana Lopez', 'ana.lopez@gmail.com', '8090123456', 'Presentador'),
 ('Jochy Santos', 'info@jochysantos.com', '8091234567', 'Conferencista'),
('Boruga', 'boruga@info.com', '8092345678', 'Conferencista'),
('Cuquin Victoria', 'cuquinvictoria@info.com', '8093456789', 'Conferencista'),
('Liondy Osoria', 'info@liondyosoria.com', '8094567890', 'Conferencista'),
('Bad Bunny', 'contacto@badbunny.com', '8001236261', 'Artista'),
('La Escuelota', 'info@laescuelota.com', '8095678901', 'Conferencista'),
('Luis Fonsi', 'info@luisfonsi', '8001232561', 'Artista'),
('DJ Adoni', 'info@djadoni.com', '8091234567', 'DJ'),
('DJ Scuff', 'scuff@info.com', '8092345678', 'DJ'), 
('Rochyrd', 'rochyrd@info.com', '8095678901', 'Artista'),
('Donaty', 'donaty@info.com', '8096789012', 'Artista'), 
('Lomiel', 'lomiel@info.com', '8097890123', 'Artista'),
('Braulio Fogon', 'brauliofogon@info.com', '8090123456', 'Artista');

INSERT INTO Contrataciones (EventoID, ParticipanteID, Precio) VALUES
(1, 27, 270000),
(1, 29, 170000),
(1, 33, 100000),
(1, 34, 100000),
(1, 35, 100000),
(1, 36, 100000),
(2, 32, 85000),
(2, 28, 210000),
(2, 30, 290000),
(2, 19, 150000),
(2, 20, 150000),
(2, 21, 150000),
(2, 22, 150000),
(3, 31, 95000),
(3, 27, 230000),
(3, 29, 260000),
(4, 32, 80000),
(4, 28, 220000),
(4, 30, 280000),
(5, 32, 90000),
(5, 27, 225000),
(5, 29, 270000),
(6, 33, 70000),
(6, 27, 215000),
(6, 29, 275000),
(7, 33, 80000),
(7, 27, 220000),
(7, 29, 270000),
(8, 32, 95000),
(8, 28, 225000),
(8, 30, 275000),
(9, 31, 100000),
(9, 27, 230000),
(9, 29, 260000),
(10, 32, 90000),
(10, 28, 225000),
(10, 30, 280000);

INSERT INTO Entradas (BoletaEventoID, Estado)
VALUES
(1, 'Utilizada'),
(2, 'Activa'),
(4, 'Activa'),
(2, 'Utilizada'),
(3, 'Utilizada'),
(5, 'Activa');

/*CREAR VIEW*/

-- Ver los eventos del ultimo mes
CREATE VIEW EventosUltimoMes AS
SELECT Nombre, Fecha, Hora, Estado FROM Eventos WHERE Fecha BETWEEN 
    DATE_SUB(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL 1 MONTH) 
    AND LAST_DAY(DATE_SUB(DATE_FORMAT(CURDATE(), '%Y-%m-01'), INTERVAL 1 MONTH));

-- Ver la inversion total de los eventos
CREATE VIEW InversionDeEventos AS
SELECT Eventos.Nombre, SUM(EventoOrganizador.Inversion) AS TotalInversion FROM Eventos
JOIN EventoOrganizador ON Eventos.EventoID = EventoOrganizador.EventoID GROUP BY Eventos.Nombre;


-- Ver eventos activos
CREATE VIEW EventosActivos AS
SELECT Eventos.Nombre, Descripcion, Fecha, Hora FROM Eventos WHERE Estado = 'Activo';

-- Ver los Organizadores
SELECT * FROM Organizadores;

-- Ver los Participantes
SELECT * FROM Participantes;

-- Consulta para ver detalles de eventos y sus ubicaciones
SELECT * FROM Eventos JOIN Ubicaciones ON Eventos.UbicacionID = Ubicaciones.UbicacionID;

-- Consulta para ver las entradass
select * from entradas;

-- Consulta para ver los tipos de boletas de cada evento
select * from boletasevento;

INSERT INTO Entradas (BoletaEventoID, Estado) VALUES
(1, 'Activa');

/*ALMACENADOS Y FUNCIONES*/

-- Ver los eventos por ciudades
    DELIMITER //
CREATE PROCEDURE AgruparEventosPorCiudades (IN Ciudad Varchar(20))
BEGIN
    SELECT Eventos.Nombre, Eventos.Fecha, Eventos.Hora, Ubicaciones.Nombre AS Ubicacion FROM Eventos
	JOIN Ubicaciones ON Eventos.UbicacionID = Ubicaciones.UbicacionID
	JOIN Ciudades ON Ubicaciones.CiudadID = Ciudades.CiudadID WHERE Ciudades.Nombre = Ciudad;
END //
DELIMITER ;

Call AgruparEventosPorCiudades('Santo Domingo');


-- Todos los detalles de un evento

DELIMITER //

CREATE PROCEDURE ObtenerInfoDeEvento(IN id INT)
BEGIN
    SELECT 
        Eventos.Nombre, Eventos.Descripcion, Eventos.Fecha, Eventos.Hora,  Eventos.estado,
        Ubicaciones.Nombre AS Ubicacion, 
        Ubicaciones.Direccion,
        (SELECT SUM(BoletasEvento.CantidadDisponible) FROM BoletasEvento  
         WHERE BoletasEvento.EventoID = Eventos.EventoID) AS TotalBoletasDisponibles FROM Eventos
         
    JOIN Ubicaciones ON Eventos.UbicacionID = Ubicaciones.UbicacionID WHERE  Eventos.EventoID = id;
END //

DELIMITER ;

CALL ObtenerInfoDeEvento(1);


-- Ver eventos dentro de un rango de fecha

DELIMITER //

CREATE PROCEDURE EventosPorFecha (IN FECHAInicio DATE, IN FechaFin DATE)
BEGIN
SELECT Nombre, Fecha, Hora, Estado FROM Eventos WHERE Fecha > FechaInicio AND Fecha < FechaFin;
END//

DELIMITER ;

CALL EventosPorFecha('2024-08-01', '2024-9-01');


-- Añadir un evento
DELIMITER //

CREATE PROCEDURE NuevoEvento(
    IN p_Nombre VARCHAR(25),
    IN p_Descripcion TEXT,
    IN p_Fecha DATE,
    IN p_Hora TIME,
    IN p_UbicacionID INT,
    IN p_Estado ENUM('Activo', 'Cancelado', 'SoldOut', 'Finalizado', 'Pospuesto')
)
BEGIN
    INSERT INTO Eventos (Nombre, Descripcion, Fecha, Hora, UbicacionID, Estado)
    VALUES (p_Nombre, p_Descripcion, p_Fecha, p_Hora, p_UbicacionID, p_Estado);
END //

DELIMITER ;


-- Ver entradas vendidas de un evento
DELIMITER //

CREATE FUNCTION EntradasVendidas(EventoID INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE TotalEntradas INT;
    
    SELECT COUNT(*) INTO TotalEntradas FROM Entradas e
	JOIN BoletasEvento be ON e.BoletaEventoID = be.BoletaEventoID WHERE be.EventoID = EventoID;
    
    RETURN TotalEntradas;
END //

DELIMITER ;

SELECT EntradasVendidas(1) AS TotalEntradas;





/*MONITEREO*/

-- Ver las conexiones activas
SHOW STATUS LIKE 'Threads_connected';

-- Lista de procesos
SHOW PROCESSLIST;





/*Mantenimiento*/

-- Optimizar tablas
OPTIMIZE TABLE eventos;

-- Actualizar estadisticas de una tabla
ANALYZE TABLE eventos;

-- Verificiar integridad de los datos
CHECK TABLE eventos;





/*CREAR ROLES*/

-- Rol admin
CREATE ROLE 'administrador';
GRANT ALL PRIVILEGES ON EventDataHub TO 'administrador' WITH GRANT OPTION;

-- Rol desarrollador
CREATE ROLE 'desarrollador';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON EventDataHub TO 'desarrollador';

-- Rol analista
CREATE ROLE 'analista';
GRANT SELECT ON *.* TO 'analista';

-- Rol Junior
CREATE ROLE 'junior';
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'junior';

-- Rol pasante
CREATE ROLE 'pasante';
GRANT SELECT ON Eventos TO 'pasante';
GRANT SELECT ON Entradas TO 'pasante';
GRANT SELECT ON Ubicaciones TO 'pasante';



-- Eliminar algun rol
DROP ROLE 'pasante';

-- Ver Usuarios creados
SELECT user, host FROM mysql.user;


-- Usuario admin
CREATE USER administrador@host IDENTIFIED BY 'strongpassword123';
GRANT 'administrador' TO administrador@host;

-- Usuario desarrollador
CREATE USER desarrollador@localhost IDENTIFIED BY 'strongpassword123';
GRANT 'desarrollador' TO desarrollador@localhost;

-- Seguridad

-- Contraseñas vencen cada 90 dias
ALTER USER administrador@host PASSWORD EXPIRE INTERVAL 90 DAY;
ALTER USER desarrollador@localhost PASSWORD EXPIRE INTERVAL 90 DAY;


/*Auditoria*/

SET GLOBAL general_log = 'ON';
SET GLOBAL slow_query_log = 'ON';

SHOW VARIABLES LIKE 'general_log_file';
SHOW VARIABLES LIKE 'slow_query_log_file';

-- Ver procesos
SHOW PROCESSLIST;

-- Estado del DB
SHOW GLOBAL STATUS;









