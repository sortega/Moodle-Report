#!/usr/bin/perl 
use strict;
use utf8;
use DBI;
use Spreadsheet::WriteExcel;
use Data::Dumper;
use Date::Manip;
use Getopt::Long;
use Data::Dumper;

##############################
# Global vars

# Options
my ($list_courses, $alumn_detail, $courses, $host, $database, $username, $password);
# Database connection
my $dbh;


sub epoch_to_excel {
	my $epoch = shift;
	return UnixDate(ParseDateString ("epoch $epoch"), "%Y-%m-%dT%H:%M:%S");
}

sub seconds_to_time {
	my $seconds = int(shift);
	my $minutes = ($seconds - $seconds % 60) / 60; $seconds %= 60;
	my $hours = ($minutes - $minutes % 60) / 60; $minutes %= 60;
	return sprintf("%02d:%02d:%02d", $hours, $minutes, $seconds);
}

my @ALUMN_HEADER = ('Nombre', 'Apellidos', 'Primer acceso', 'Último acceso',
       	'Tiempo total empleado', 'Secciones accedidas', 'Porcentaje accedido');
sub write_alumn_header {
	my ($sheet, $formats, $next_row, $alumn_number) = @_;
	$sheet->write_row($next_row, 0, [$alumn_number, @ALUMN_HEADER], 
		$formats->{BoldFormat});
}

sub write_alumn {
	my ($sheet, $formats, $next_row, $alumn_number, $alumn) = @_;
	print("\t$alumn->{lastname}, $alumn->{firstname}\n");
	
	if ($alumn_detail) {
		write_alumn_header($sheet, $formats, $next_row++, $alumn_number);
	}
	my $alumn_row = $next_row;

	# General data
	$sheet->write_string($next_row, 1, $alumn->{'firstname'});
	$sheet->write_string($next_row, 2, $alumn->{'lastname'});
	$sheet->write_date_time($next_row, 3, epoch_to_excel($alumn->{'first_access'}),
		$formats->{DateFormat});
	$sheet->write_date_time($next_row, 4, epoch_to_excel($alumn->{'last_access'}),
		$formats->{DateFormat});
	$next_row++;

	# Views
	if ($alumn_detail) {
		$next_row++;
		$sheet->write_string($next_row++, 1, "Secciones visitadas",
			$formats->{BoldFormat});
		$sheet->write_row($next_row++, 1, ['Sección', 'Visitas'],
			$formats->{BoldFormat}); }

	my $views_query = $dbh->prepare( <<EOS );
SELECT s.section_title, IFNULL(views, 0) as views, time
FROM 
(
  select * 
  from just_sections
  where course_id = ?
) as s
LEFT OUTER JOIN 
( 
	(SELECT res.id AS `section_id`, 
	       `res`.`name` AS `section_title`, 
	       COUNT(*)     AS `views`, 
	       NULL         AS `time` 
	FROM   
	       `mdl_log` `log`, 
	       `mdl_resource` `res`, 
		mdl_course_modules cm
	WHERE  log.module='resource' 
		 AND log.action='view'
		 AND `cm`.`id` = `log`.`cmid` 
		 AND cm.instance=res.id
		 AND log.course = ?
		 AND `log`.`userid` = ?
	GROUP  BY `res`.`id` )
	UNION
       (SELECT `scoes`.`id`              AS `section_id`, 
	       `scoes`.`title`           AS `section_title`, 
	       Max(`track`.`attempt`)    AS `views`, 
	       SUM(Greatest(Time_to_sec(Substr(`track`.`value`, 1, 8)), 1)) AS `time` 
	FROM   `mdl_scorm` `scorm`, 
	       `mdl_scorm_scoes` `scoes`, 
	       `mdl_scorm_scoes_track` `track`
	WHERE   ( `scorm`.`id` = `scoes`.`scorm` ) 
		 AND ( `scoes`.`id` = `track`.`scoid` ) 
		 AND ( `track`.`element` = 'cmi.core.total_time' )
		 AND scorm.course = ?
		 AND `track`.`userid` = ?
	GROUP  BY `scoes`.`id` )
) AS sub
ON (s.section_id = sub.section_id) 
ORDER BY s.section_id
EOS
	$views_query->execute($alumn->{'course_id'},
		 $alumn->{'course_id'}, $alumn->{'user_id'},
		 $alumn->{'course_id'}, $alumn->{'user_id'});

	my $sections = 0;
	my $visited_sections = 0;
	my $total_time = 0;
	while (my $view = $views_query->fetchrow_hashref()) {
		if ($alumn_detail) {
			$sheet->write_string($next_row, 1, $view->{'section_title'});
			$sheet->write_number($next_row, 2, $view->{'views'});
			$next_row++;
		}

		$sections++;
		$visited_sections++ if ($view->{'views'} > 0);
		$total_time += $view->{'time'};
	}
	
	$sheet->write_string($alumn_row, 5, seconds_to_time($total_time));
	$sheet->write_string($alumn_row, 6, "$visited_sections/$sections");
	$sheet->write_number($alumn_row, 7, $visited_sections/$sections, 
		$formats->{PercentFormat});


	# Results
	if ($alumn_detail) {
		$next_row++;
		$sheet->write_string($next_row++, 1, "Evaluaciones", $formats->{BoldFormat});
		$sheet->write_row($next_row++, 1, ['Nombre', 'Calificación'], $formats->{BoldFormat});

		my $results_query = $dbh->prepare( <<EOS );
SELECT title, IFNULL(result, '-') as result
FROM 
(
  SELECT * 
  FROM just_evaluation
  WHERE course_id = ?
) AS l
LEFT OUTER JOIN 
( 
  SELECT *
  FROM just_results
  WHERE course_id = ? AND user_id = ?
) AS r
ON (l.course_id = r.course_id AND l.fkid = r.fkid AND l.type = r.type) 
ORDER BY l.type, l.fkid
EOS
		$results_query->execute($alumn->{'course_id'}, $alumn->{'course_id'},
			$alumn->{'user_id'});

		while (my $result = $results_query->fetchrow_hashref()) {
			$sheet->write_string($next_row, 1, $result->{'title'});
			$sheet->write_string($next_row, 2, $result->{'result'});
			$next_row++;
		}

		$next_row++;
	}


	return $next_row;
}

sub write_course {
	my ($workbook, $formats, $course) = @_;
	print "\nHoja para $course->{shortname}...\n";
	my $sheet = $workbook->add_worksheet(substr($course->{'shortname'},0,30));
	$sheet->set_column(1, 1, 35);
	$sheet->set_column(2, 2, 25);
	$sheet->set_column(3, 4, 15);
	$sheet->set_column(5, 6, 15, $formats->{RightAlignFormat});
	$sheet->set_column(7, 7, 15);

	# Course header
	$sheet->write_string(0, 0, $course->{'fullname'}, $formats->{TitleFormat});

	my $alumn_query = $dbh->prepare(
		"SELECT * FROM just_alumn WHERE course_id = ? ORDER BY lastname, firstname");
	$alumn_query->execute($course->{'id'});

	my $next_row = 2;
	my $alumn_number = 1;
	if (not $alumn_detail) {
		write_alumn_header($sheet, $formats, $next_row++, '');
	}
	while (my $alumn = $alumn_query->fetchrow_hashref()) {
		$next_row = write_alumn($sheet, $formats, $next_row, $alumn_number, $alumn);
		$alumn_number++;
	}

	$sheet->activate();
}

sub write_report {
	print "Escribiendo informe...\n";
	my $filename = shift;

	my $workbook = Spreadsheet::WriteExcel->new($filename);
	my $formats = {
		DateFormat => $workbook->add_format(num_format => 'dd/mm/yy hh:MM'),
		PercentFormat => $workbook->add_format(num_format => '0.0%'),
		RightAlignFormat => $workbook->add_format(align => 'right'),
		TitleFormat => $workbook->add_format(bold => 1, size => 24),
		BoldFormat => $workbook->add_format(bold => 1, size => 12),
	};
	for my $course (@{$courses}) {
		write_course ($workbook, $formats, $course);
	}
	print "Informe finalizado.\n";
}

sub list_courses {
	my $courses_query = $dbh->prepare(
		"select id, fullname from mdl_course where id > 1");
	$courses_query->execute();
	print "\tid#\tNombre del curso\n\n";
	while (my $course = $courses_query->fetchrow_hashref()) {
		printf("\t% 3d\t%s\n", $course->{'id'}, $course->{'fullname'});
	}
}

sub select_courses {
	my $course_text = shift;
	my %course_ids = ();

	for (split /,/, $course_text) {
		if (/^(\d+)-(\d+)$/) {
			$course_ids{$_} = 1 for $1..$2;
		} elsif (/^(\d+)$/) {
			$course_ids{$1} = 1;
		} else {
			usage("Formato de selección de cursos inválido");
		}
	}

	my @course_ids = keys %course_ids;

	my $courses;
	if (@course_ids) {
		my $courses_query = $dbh->prepare(
			"select id, fullname, shortname from mdl_course where id in ". 
			"(" . (join ',', @course_ids) .")");
		$courses_query->execute();
		$courses = $courses_query->fetchall_arrayref({});
		usage("Algunos cursos no existen")
	       		unless scalar(@course_ids) == @{$courses};
	} else {
		my $courses_query = $dbh->prepare(
			"select id, fullname, shortname from mdl_course where id > 1");
		$courses_query->execute();
		$courses = $courses_query->fetchall_arrayref({});
	}

	return $courses;
}

sub usage {
	my $message = shift;
	$message .= "\n" if ($message);
	$message = '' unless ($message);
	die <<EOM 
$message
uso: 
$0 [--alumn-detail] [--courses=3,5,6-12] [--host=localhost] [--database=moodle] \
	--username=usuario --password=password fichero.xls
    Crea un informe como hoja de cálculo para los cursos seleccionados (o todos)

$0 --list-courses [--host=localhost] [--database=moodle] --username=usuario \
	--password=password 
    Lista los cursos disponibles
EOM
}

sub argument_parsing {
	GetOptions(
		# Listing courses
		"list-courses" => \$list_courses,

		# Reporting 
		"alumn-detail" => \$alumn_detail,
		"courses=s" => \$courses,
		"host=s" => \$host,
		"database=s" => \$database,
		"username=s" => \$username,
		"password=s" => \$password,
	) or usage("Opciones incorrectas");

	# Database connection
	$host = "localhost" unless ($host);
	$database = "moodle" unless ($database);
	usage("El usuario y la contraseña son obligatorios")
       		unless $username and $password;
	$dbh = DBI->connect("dbi:mysql:host=$host;database=$database",
		$username, $password) 
		or die "No se puede conectar con la base de datos";

	if ($list_courses) {
		usage("No especifique un fichero de destino") unless @ARGV == 0;
		list_courses();

	} else { # Reporting
		usage("Especifique un fichero de destino") unless @ARGV == 1;
		$courses = select_courses($courses) or usage();

		my $filename = shift @ARGV;
		write_report($filename);
	}
}

argument_parsing();
