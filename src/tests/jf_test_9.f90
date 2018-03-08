!*****************************************************************************************
!> author: Jacob Williams
!  date: 3/2/2015
!
! Module for the ninth unit test.

module jf_test_9_mod

    use json_module
    use, intrinsic :: iso_fortran_env , only: error_unit, output_unit, wp => real64

    implicit none

    !small file - 0.0 sec : http://www.json-generator.com
    !character(len=*),parameter :: filename = 'random1.json'

    !7 MB - 5.4 sec : http://www.json-generator.com
    character(len=*),parameter :: filename = 'big.json'

    !13 MB - 7.6 sec : http://mtgjson.com
    !character(len=*),parameter :: filename = 'AllSets.json'

    !....WARNING: this file is causing some error.... (bug in code?)
    !100 MB - takes forever... : https://github.com/seductiveapps/largeJSON
    !character(len=*),parameter :: filename = '100mb.json'

    !small file that contains unicode characters:
    !character(len=*),parameter :: filename = 'hello-world-ucs4.json'  !!!! test !!!!

    character(len=*),parameter :: dir = '../files/inputs/' !working directory

contains

    subroutine test_9(error_cnt)

    !! Open a random JSON file generated by http://www.json-generator.com

    implicit none

    integer,intent(out) :: error_cnt

    type(json_file) :: f
    real :: tstart, tend
    character(len=:),allocatable :: str

    error_cnt = 0

    write(error_unit,'(A)') ''
    write(error_unit,'(A)') '================================='
    write(error_unit,'(A)') '   EXAMPLE 9a '
    write(error_unit,'(A)') '================================='

    write(error_unit,'(A)') ''
    write(error_unit,'(A)') '  Load a file using json_file%load_file'
    write(error_unit,'(A)') ''
    write(error_unit,'(A)') 'Loading file: '//trim(filename)

    call cpu_time(tstart)
    call f%load_file(dir//filename) ! will automatically call initialize() with defaults
    call cpu_time(tend)
    write(error_unit,'(A,1X,F10.3,1X,A)') 'Elapsed time: ',tend-tstart,' sec'

    if (f%failed()) then
        call f%print_error_message(error_unit)
        error_cnt = error_cnt + 1
    else
        write(error_unit,'(A)') 'File successfully read'
    end if
    write(error_unit,'(A)') ''

    !cleanup:
    call f%destroy()

    write(error_unit,'(A)') ''
    write(error_unit,'(A)') '================================='
    write(error_unit,'(A)') '   EXAMPLE 9b '
    write(error_unit,'(A)') '================================='

    write(error_unit,'(A)') ''
    write(error_unit,'(A)') '  Load a file using json_file%load_from_string'
    write(error_unit,'(A)') ''
    write(error_unit,'(A)') 'Loading file: '//trim(filename)

    call cpu_time(tstart)
    call read_file(dir//filename, str)

    if (allocated(str)) then
        call f%load_from_string(str)
        call cpu_time(tend)
        write(error_unit,'(A,1X,F10.3,1X,A)') 'Elapsed time to parse: ',tend-tstart,' sec'
        if (f%failed()) then
            call f%print_error_message(error_unit)
            error_cnt = error_cnt + 1
        else
            write(error_unit,'(A)') 'File successfully read'
        end if
        write(error_unit,'(A)') ''
        !write(error_unit,'(A)') str   !!!! test !!!!
        !write(error_unit,'(A)') ''    !!!! test !!!!
    else
        write(error_unit,'(A)') 'Error loading file'
    end if

    !cleanup:
    call f%destroy()

    end subroutine test_9

    subroutine read_file(filename,str)

    !! Reads the contents of the file into the allocatable string str.
    !! If there are any problems, str will be returned unallocated.
    !!
    !!@warning Will this routine work if the file contains unicode characters??

    implicit none

    character(len=*),intent(in) :: filename
    character(len=:),allocatable,intent(out) :: str

    integer :: iunit,istat,filesize

    open( newunit = iunit,&
          file    = filename,&
          status  = 'OLD',&
          form    = 'UNFORMATTED',&
          access  = 'STREAM',&
          iostat  = istat )

    if (istat==0) then
        inquire(file=filename, size=filesize)
        if (filesize>0) then
            allocate( character(len=filesize) :: str )
            read(iunit,pos=1,iostat=istat) str
            if (istat/=0) deallocate(str)
            close(iunit, iostat=istat)
        end if
    end if

    end subroutine read_file

end module jf_test_9_mod
!*****************************************************************************************
#ifndef INTERGATED_TESTS
!*****************************************************************************************
program jf_test_9

    !! Ninth unit test.

    use jf_test_9_mod , only: test_9
    implicit none
    integer :: n_errors
    n_errors = 0
    call test_9(n_errors)
    if (n_errors /= 0) stop 1

end program jf_test_9
!*****************************************************************************************
#endif