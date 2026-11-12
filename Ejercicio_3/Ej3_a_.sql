-- SQLBook: Code
SELECT Nombre as Persona_que_publica, p.`Texto`, COUNT (r.IDPub) as total_de_reacciones
FROM Publicacion as p
JOIN Usuario as u ON p.IDU = u.IDU
JOIN Reaccionar as r ON r.IDPub = p.IDPub
GROUP BY u.Nombre, u.IDU, p.IDPub
ORDER BY total_de_reacciones DESC





