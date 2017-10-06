exec { "apt-update":
    command => "/usr/bin/apt-get update"
}
package { ["openjdk-7-jre", "mysql-server"]:
    ensure => installed,
    require => Exec["apt-update"]
}
service {"mysql":
	ensure => running,
	enable => true,
	hasstatus => true,
	hasrestart => true,
	require => Package["mysql-server"]
}

exec { "CreateBD":
    command => "mysqladmin -uroot create ArchiveDB",
	unless => "mysql -uroot ArchiveDB",
	path => "/usr/bin",
	require => Service["mysql"]
}

exec { "AddPasswordInAccountBD":
	command => "mysql -uroot -e \"GRANT ALL PRIVILEGES ON * TO 'usrboss'@'%' IDENTIFIED BY 'Rota2017';\" ArchiveDB",
	unless => "mysql -uusrboss -pRota2017 ArchiveDB",
	path => "/usr/bin",
	require =>Exec[ "CreateBD"]
}

exec { "CreateTBArchive":
	command => "create table tbarchive (IDArchive INT PRIMARY KEY, Name VARCHAR(100), path VARCHAR(100), owner VARCHAR (100));",
	unless => "mysql -uusrboss -pRota2017 TBArchive",
	path => "/usr/bin",
	require =>Exec[ "CreateBD"]
}
exec { "CreateTBUser":
	command => "create table ArchiveDB.tbuser (IDuser INT PRIMARY KEY AUTO_INCREMENT, Nameuser VARCHAR(100), Emailuser VARCHAR(100), Password VARCHAR(100) NOT NULL);",
	unless => "mysql -uroot TBArchive",
	path => "/usr/bin",
	require =>Exec[ "CreateBD"]
}

define file_line($file, $line) {
    exec { "/bin/echo '${line}' >> '${file}'":
        unless => "/bin/grep -qFx '${line}' '${file}'"
    }
}
