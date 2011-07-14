#!/usr/bin/perl
use CGI;
use DBI;
use Spreadsheet::WriteExcel;
use Data::Dumper;
use utf8;
use strict;
use warnings;

use constant HOST => 'localhost';
use constant USER => 'username';
use constant PASSWORD => 'password';

my $q = CGI->new;
my $dbh;

my @ALUMN_HEADER = ('Apellidos', 'Nombre', 'DNI', 'Primer acceso', 'Último acceso', 'Conexión a tiempo',
       	'Tiempo total de conexión', 'Nº Evaluaciones', 'Calificación final');
sub write_alumn_header {
	my ($sheet, $formats, $row) = @_;
	$sheet->write_row($row, 0, \@ALUMN_HEADER, $formats->{BoldFormat});
}

my @GRADES_HEADER = ('Ejercicio', 'Fecha de entrega', 'Calificación');
sub write_grades_header {
	my ($sheet, $formats, $row) = @_;
	$sheet->write_row($row, 3, \@GRADES_HEADER, $formats->{BoldFormat});
}

sub write_grades_detail {
	my ($sheet, $formats, $next_row, $alumn, $course) = @_;

	my $grades_query = $dbh->prepare(
		"SELECT * FROM report_controles WHERE course_id = ? AND user_id = ? ORDER BY date");
	$grades_query->execute($course->{'id'}, $alumn->{'alumn_id'});
	while (my $grade = $grades_query->fetchrow_hashref()) {
		$sheet->write_row($next_row++, 3, [
			$grade->{'name'},
			$grade->{'date'},
			$grade->{'grade'},
		]);
	}

	return $next_row;
}

sub write_alumn {
	my ($sheet, $formats, $next_row, $alumn, $course) = @_;
	
	$sheet->write_row($next_row++, 0, [
		$alumn->{'apellidos'},
		$alumn->{'nombre'},
		$alumn->{'dni'},
		$alumn->{'primera_conexion'},
		$alumn->{'ultima_conexion'},
		$alumn->{'conectado_a_tiempo'},
		$alumn->{'tiempo_total'},
		$alumn->{'evaluaciones'},
		$alumn->{'calificacion_final'},
	]);

	write_grades_header($sheet, $formats, $next_row++);
	return write_grades_detail($sheet, $formats, $next_row, $alumn, $course);
}


sub write_course {
	my ($workbook, $formats, $course) = @_;
	my $sheet = $workbook->add_worksheet(substr($course->{'shortname'},0,30));
	
	$sheet->set_column(0, 1, 25, $formats->{WhiteBackground});
	$sheet->set_column(2, 2, 10, $formats->{WhiteBackground});
	$sheet->set_column(3, 3, 22, $formats->{WhiteBackground});
	$sheet->set_column(4, 5, 18, $formats->{WhiteBackground});
	$sheet->set_column(6, 6, 25, $formats->{CenteredWhiteBg});
	$sheet->set_column(7, 8, 18, $formats->{CenteredWhiteBg});
	$sheet->set_column(9, 25, 18, $formats->{CenteredWhiteBg});
	#$sheet->set_column(5, 6, 15, $formats->{RightAlignFormat});
	#$sheet->set_column(7, 7, 15);

	$sheet->set_row(0,30,$formats->{FirstRow});
	
	# Course header
	$sheet->write_string(0, 0, $course->{'fullname'}, $formats->{TitleFormat});

	my $alumn_query = $dbh->prepare(
		"SELECT * FROM report WHERE curso = ? ORDER BY apellidos, nombre");
	$alumn_query->execute($course->{'id'});

	my $next_row = 2;

	write_alumn_header($sheet, $formats, $next_row++);
	while (my $alumn = $alumn_query->fetchrow_hashref()) {
		$next_row = write_alumn($sheet, $formats, $next_row, $alumn, $course);
	}

	$sheet->activate();
}


sub write_report {
	my $course = shift;
	my $workbook = Spreadsheet::WriteExcel->new('-');
	my $azul = $workbook->set_custom_color(40,0,62,186);
	my $formats = {
		DateFormat => $workbook->add_format(num_format => 'dd/mm/yy hh:MM'),
		PercentFormat => $workbook->add_format(num_format => '0.0%'),
		RightAlignFormat => $workbook->add_format(align => 'right'),
		CenterAlignFormat => $workbook->add_format(align => 'center'),
		TitleFormat => $workbook->add_format(bold => 1, size => 24, bg_color => $azul, color => 'white'),
		BoldFormat => $workbook->add_format(bold => 1, size => 12),
		FirstRow => $workbook->add_format(bg_color => $azul),
		WhiteBackground => $workbook->add_format(bg_color => 'white', color => 'black'),
		CenteredWhiteBg => $workbook->add_format(bg_color => 'white', color => 'black', align => 'center'),
	};
	write_course ($workbook, $formats, $course);
}

sub find_course {
	my $course_id = shift;

	my $courses_query = $dbh->prepare(
			"select id, fullname, idnumber as shortname from mdl_course where id=$course_id");
	$courses_query->execute();
	my $course = $courses_query->fetchrow_hashref();
	die("Course $course_id not found") unless $course;
	return $course;
}

my @course_ids = $q->param('course_id');
if (@course_ids) {
	$dbh = DBI->connect("dbi:mysql:host=".HOST.";database=moodle-fcupm",
			USER, PASSWORD) 
		or die "Cannot access the database";

	print $q->header(
		-type => 'application/x-excel',
		-Content_disposition => 'attachment; filename=report.xls',
	);

	my $course = find_course($course_ids[0]);
	write_report($course);

} else {
	print $q->header(
			-type => 'text/plain',
			-status => 400,
			);
	print "Parameter course_id was not specified\n";
}



# vim:set syntax=perl:
