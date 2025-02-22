-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 22, 2025 at 10:58 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_perpus`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteBuku` (IN `p_id_buku` INT)   BEGIN
    DELETE FROM buku WHERE id_buku = p_id_buku;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeletePeminjaman` (IN `p_id_peminjaman` INT)   BEGIN
    DELETE FROM peminjaman WHERE id_peminjaman = p_id_peminjaman;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteSiswa` (IN `p_id_siswa` INT)   BEGIN
    DELETE FROM siswa WHERE id_siswa = p_id_siswa;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllBuku` ()   BEGIN
    SELECT * FROM buku;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllPeminjaman` ()   BEGIN
    SELECT * FROM peminjaman;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllSiswa` ()   BEGIN
    SELECT * FROM siswa;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSemuaBuku` ()   BEGIN
    SELECT b.id_buku, b.judul_buku, b.penulis, b.kategori, b.stok,
           CASE
               WHEN p.id_peminjaman IS NULL THEN 'Belum Pernah Dipinjam'
               ELSE 'Pernah Dipinjam'
           END AS status_peminjaman
    FROM buku b
    LEFT JOIN peminjaman p ON b.id_buku = p.id_buku;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSemuaSiswa` ()   BEGIN
    SELECT s.id_siswa, s.nama, s.kelas,
           CASE
               WHEN p.id_peminjaman IS NULL THEN 'Belum Pernah Meminjam'
               ELSE 'Pernah Meminjam'
           END AS status_peminjaman
    FROM siswa s
    LEFT JOIN peminjaman p ON s.id_siswa = p.id_siswa;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSiswaPernahPinjam` ()   BEGIN
    SELECT DISTINCT s.id_siswa, s.nama, s.kelas
    FROM siswa s
    JOIN peminjaman p ON s.id_siswa = p.id_siswa;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertBuku` (IN `judul_buku` VARCHAR(225), IN `penulis` VARCHAR(225), IN `kategori` VARCHAR(100), IN `stok` INT)   BEGIN
    INSERT INTO buku (judul_buku, penulis, kategori, stok) 
    VALUES (judul_buku, penulis, kategori, stok);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertPeminjaman` (IN `id_siswa` INT, IN `id_buku` INT, IN `tanggal_pinjam` DATE, IN `tanggal_kembali` DATE, IN `status` ENUM('Dipinjam','Dikembalikan'))   BEGIN
    INSERT INTO peminjaman (id_siswa, id_buku, tanggal_pinjam, tanggal_kembali, status) 
    VALUES (id_siswa, id_buku, tanggal_pinjam, tanggal_kembali, status);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertSiswa` (IN `nama` VARCHAR(50), IN `kelas` VARCHAR(50))   BEGIN
    INSERT INTO siswa (nama, kelas) VALUES (nama, kelas);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `KembalikanBuku` (IN `p_id_peminjaman` INT, IN `p_id_buku` INT)   BEGIN
    -- Update status peminjaman dan set tanggal_kembali dengan CURRENT_DATE
    UPDATE peminjaman 
    SET status = 'Dikembalikan', tanggal_kembali = CURRENT_DATE 
    WHERE id_peminjaman = p_id_peminjaman;
    
    -- Tambah stok buku
    UPDATE buku SET stok = stok + 1 WHERE id_buku = p_id_buku;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PinjamBuku` (IN `p_id_siswa` INT, IN `p_id_buku` INT, IN `p_tanggal_pinjam` DATE)   BEGIN
    -- Insert record peminjaman dengan status 'Dipinjam' dan tanggal_kembali NULL
    INSERT INTO peminjaman (id_siswa, id_buku, tanggal_pinjam, tanggal_kembali, status)
    VALUES (p_id_siswa, p_id_buku, p_tanggal_pinjam, NULL, 'Dipinjam');
    
    -- Kurangi stok buku
    UPDATE buku SET stok = stok - 1 WHERE id_buku = p_id_buku;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ReturnBook` (IN `p_id_peminjaman` INT, IN `p_id_buku` INT)   BEGIN
    -- Update status peminjaman menjadi 'Dikembalikan' dan set tanggal_kembali dengan CURRENT_DATE()
    UPDATE peminjaman
    SET status = 'Dikembalikan',
        tanggal_kembali = CURRENT_DATE()
    WHERE id_peminjaman = p_id_peminjaman;
    
    -- Tambahkan stok buku karena buku sudah dikembalikan
    UPDATE buku
    SET stok = stok + 1
    WHERE id_buku = p_id_buku;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateBuku` (IN `p_id_buku` INT, IN `p_judul_buku` VARCHAR(255), IN `p_penulis` VARCHAR(255), IN `p_kategori` VARCHAR(100), IN `p_stok` INT)   BEGIN
    UPDATE buku 
    SET judul_buku = p_judul_buku, 
        penulis = p_penulis, 
        kategori = p_kategori, 
        stok = p_stok
    WHERE id_buku = p_id_buku;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdatePeminjaman` (IN `p_id_peminjaman` INT, IN `p_id_siswa` INT, IN `p_id_buku` INT, IN `p_tanggal_pinjam` DATE, IN `p_tanggal_kembali` DATE, IN `p_status` ENUM('Dipinjam','Dikembalikan'))   BEGIN
    UPDATE peminjaman
    SET id_siswa = p_id_siswa,
        id_buku = p_id_buku,
        tanggal_pinjam = p_tanggal_pinjam,
        tanggal_kembali = p_tanggal_kembali,
        status = p_status
    WHERE id_peminjaman = p_id_peminjaman;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSiswa` (IN `p_id_siswa` INT, IN `p_nama` VARCHAR(255), IN `p_kelas` VARCHAR(50))   BEGIN
    UPDATE siswa 
    SET nama = p_nama, 
        kelas = p_kelas
    WHERE id_siswa = p_id_siswa;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `buku`
--

CREATE TABLE `buku` (
  `id_buku` int(11) NOT NULL,
  `judul_buku` varchar(255) DEFAULT NULL,
  `penulis` varchar(255) DEFAULT NULL,
  `kategori` varchar(100) DEFAULT NULL,
  `stok` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `buku`
--

INSERT INTO `buku` (`id_buku`, `judul_buku`, `penulis`, `kategori`, `stok`) VALUES
(1, 'Algoritma dan Pemrograman', 'Andi Wijaya', 'Teknologi', 5),
(2, 'Dasar-dasar Database', 'Budi Santoso', 'Teknologi', 8),
(3, 'Matematika Diskrit', 'Rina Sari', 'Matematika', 4),
(4, 'Sejarah Dunia', 'John Smith', 'Sejarah', 3),
(5, 'Pemrograman Web dengan PHP', 'Eko Prasetyo', 'Teknologi', 8),
(6, 'Jaringan Komputer', 'Ahmad Fauzi', 'Teknologi', 5);

-- --------------------------------------------------------

--
-- Table structure for table `peminjaman`
--

CREATE TABLE `peminjaman` (
  `id_peminjaman` int(11) NOT NULL,
  `id_siswa` int(11) DEFAULT NULL,
  `id_buku` int(11) DEFAULT NULL,
  `tanggal_pinjam` date DEFAULT NULL,
  `tanggal_kembali` date DEFAULT NULL,
  `status` enum('Dipinjam','Dikembalikan') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `peminjaman`
--

INSERT INTO `peminjaman` (`id_peminjaman`, `id_siswa`, `id_buku`, `tanggal_pinjam`, `tanggal_kembali`, `status`) VALUES
(1, 1, 2, '2025-02-01', '2025-02-22', 'Dikembalikan'),
(2, 2, 5, '2025-01-28', '2025-02-04', 'Dikembalikan'),
(3, 3, 3, '2025-02-02', '2025-02-09', 'Dipinjam'),
(4, 4, 4, '2025-01-30', '2025-02-06', 'Dikembalikan'),
(5, 5, 1, '2025-01-25', '2025-02-01', 'Dikembalikan'),
(9, 2, 3, '2025-02-10', '2025-02-17', 'Dipinjam'),
(10, 2, 3, '2025-02-15', NULL, 'Dipinjam');

-- --------------------------------------------------------

--
-- Table structure for table `siswa`
--

CREATE TABLE `siswa` (
  `id_siswa` int(11) NOT NULL,
  `nama` varchar(255) DEFAULT NULL,
  `kelas` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `siswa`
--

INSERT INTO `siswa` (`id_siswa`, `nama`, `kelas`) VALUES
(1, 'Andi Saputra', 'X-RPL'),
(2, 'Budi Wijaya', 'X-TKJ'),
(3, 'Citra Lestari', 'XI-RPL'),
(4, 'Dewi Kurniawan', 'XI-TKJ'),
(5, 'Eko Prasetyo', 'XII-RPL'),
(6, 'Olivia Hernanda', 'XI-RPL');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `buku`
--
ALTER TABLE `buku`
  ADD PRIMARY KEY (`id_buku`);

--
-- Indexes for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD PRIMARY KEY (`id_peminjaman`),
  ADD KEY `id_siswa` (`id_siswa`),
  ADD KEY `id_buku` (`id_buku`);

--
-- Indexes for table `siswa`
--
ALTER TABLE `siswa`
  ADD PRIMARY KEY (`id_siswa`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `buku`
--
ALTER TABLE `buku`
  MODIFY `id_buku` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `peminjaman`
--
ALTER TABLE `peminjaman`
  MODIFY `id_peminjaman` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `siswa`
--
ALTER TABLE `siswa`
  MODIFY `id_siswa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD CONSTRAINT `peminjaman_ibfk_1` FOREIGN KEY (`id_siswa`) REFERENCES `siswa` (`id_siswa`),
  ADD CONSTRAINT `peminjaman_ibfk_2` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id_buku`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
