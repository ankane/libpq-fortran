module m_fe_exec
   implicit none
   private

   public :: PQexec
   public :: PQresultStatus
   public :: PQresultErrorMessage
   public :: PQgetvalue
   public :: PQntuples
   public :: PQnfields
   public :: PQfname
   public :: PQfnumber
   public :: PQclear
   public :: PQgetisnull

   public :: PQfreemem


contains


   !==================================================================!
   ! Command Execution Functions

   !== Main Functions

   function PQexec(conn, query) result(res)
      use, intrinsic :: iso_c_binding
      implicit none
      
      type(c_ptr), intent(in) :: conn
      character(*), intent(in) :: query
      character(:, kind=c_char), allocatable :: c_query
      type(c_ptr) :: res
      
      interface
         ! Interface to PQexec in interfaces/libpq/fe-exec.c:
         !
         ! PGresult *PQexec(PGconn *conn, const char *query)
         !
         function c_PQ_exec (conn, query) bind(c, name='PQexec') result(pgresult)
            import c_ptr, c_char
            implicit none
            type(c_ptr), intent(in), value :: conn
            
            ! To pass a string to C, declare an array of type 'character' with kind 'c_char'.
            character(1, kind=c_char), intent(in) :: query(*)

            type(c_ptr) :: pgresult
         end function c_PQ_exec
      end interface

      ! Append a C null character to the end of the query.
      c_query = query//c_null_char

      res = c_PQ_exec(conn, c_query)

   end function PQexec

   
   ! function PQexecParams
   ! function PQprepare
   ! function PQexecPrepared
   ! function PQdescribePrepared
   ! function PQdescribePortal


   function PQresultStatus(pgresult) result(res)
      use, intrinsic :: iso_fortran_env
      use, intrinsic :: iso_c_binding, only: c_ptr, c_int
      implicit none
      type(c_ptr), intent(in) :: pgresult
      integer(int32) :: res

      interface
         ! Interface to PQresultStatus in interfaces/libpq/fe-exec.c:
         !
         ! ExecStatusType PQresultStatus(const PGresult *res)
         !
         function c_PQ_result_status(pgresult) bind(c, name='PQresultStatus') result(res)
            import c_ptr, c_int
            implicit none
            type(c_ptr), intent(in), value :: pgresult
            integer(c_int) :: res
         end function c_PQ_result_status
      end interface
      
      res = c_PQ_result_status(pgresult)

   end function PQresultStatus


   ! function PQresStatus


   function PQresultErrorMessage(pgresult) result(res)
      use :: character_pointer_wrapper
      use, intrinsic :: iso_c_binding
      implicit none
      type(c_ptr), intent(in) :: pgresult
      character(:, kind=c_char), pointer :: res

      interface
         ! Interface to PQresultErrorMessage in interface/libpq/fe-exec.c:
         !
         ! char *PQresultErrorMessage(const PGresult *res)
         !
         function c_PQ_result_error_message (res) bind(c, name='PQresultErrorMessage')
            import c_ptr
            implicit none
            type(c_ptr), intent(in), value :: res
            type(c_ptr) :: c_PQ_result_error_message
         end function c_PQ_result_error_message
      end interface

      res => c_to_f_charpointer(c_PQ_result_error_message(pgresult))

   end function PQresultErrorMessage


   ! function PQresultVerboseErrorMessage
   ! function PQresultErrorField


   !-- Delete a PGresult
   subroutine PQclear(res)
      use, intrinsic :: iso_c_binding
      implicit none
      
      type(c_ptr), intent(in) :: res

      interface
         ! Interface to PQclear in interface/libpq/fe-exec.c:
         !
         ! void PQclear(PGresult *res)
         !
         subroutine c_PQ_clear(res) bind(c, name='PQclear')
            import c_ptr
            implicit none
            type(c_ptr), intent(in), value :: res
         end subroutine c_PQ_clear
      end interface

      call c_PQ_clear(res)

   end subroutine PQclear

   
   !== Retrieving Query Result Information

   function PQntuples(pgresult) result(res)
      use, intrinsic :: iso_fortran_env
      use, intrinsic :: iso_c_binding
      implicit none
      type(c_ptr), intent(in) :: pgresult
      integer(int32) :: res

      interface
         ! Interface to PQntuples in interface/libpq/fe-exec.c:
         !
         ! int PQntuples(const PGresult *res)
         !
         function c_PQ_n_tuples (pgresult) bind(c, name='PQntuples')
            import c_ptr, c_int
            implicit none
            type(c_ptr), intent(in), value :: pgresult
            integer(c_int) :: c_PQ_n_tuples
         end function c_PQ_n_tuples
      end interface

      res = c_PQ_n_tuples(pgresult)

   end function PQntuples


   function PQnfields(pgresult) result(res)
      use, intrinsic :: iso_fortran_env
      use, intrinsic :: iso_c_binding
      implicit none
      type(c_ptr), intent(in) :: pgresult
      integer(int32) :: res

      interface
         ! Interface to PQnfields in interface/libpq/fe-exec.c:
         !
         ! int PQnfields(const PGresult *res)
         !
         function c_PQ_n_fields (pgresult) bind(c, name='PQnfields')
            import c_ptr, c_int
            implicit none
            type(c_ptr), intent(in), value :: pgresult
            integer(c_int) :: c_PQ_n_fields
         end function c_PQ_n_fields
      end interface

      res = c_PQ_n_fields(pgresult)
   end function PQnfields

   function PQfname(pgresult, field_num) result(res)
      use :: character_pointer_wrapper
      use, intrinsic :: iso_fortran_env, only:int32
      use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_char
      implicit none
      type(c_ptr), intent(in) :: pgresult
      integer(int32), intent(in) :: field_num
      character(:, kind=c_char), pointer :: res

      interface
         ! Interface to PQfname in src/interface/libpq/fe-exec.c:
         !
         ! char *PQfname(const PGresult *res, int field_num)
         function c_PQ_field_name (pgresult, c_field_num) bind(c, name='PQfname')
            import c_ptr, c_int
            implicit none
            type(c_ptr), intent(in), value :: pgresult
            integer(c_int), intent(in), value :: c_field_num
            type(c_ptr) :: c_PQ_field_name
         end function c_PQ_field_name
      end interface
      
      res => c_to_f_charpointer(c_PQ_field_name(pgresult, field_num ))

   end function PQfname

   
   function PQfnumber (pgresult, column_name)
      use :: character_pointer_wrapper
      use, intrinsic :: iso_c_binding
      implicit none
      
      type(c_ptr), intent(in) :: pgresult
      character(*), intent(in) :: column_name
      character(:, kind=c_char), allocatable :: c_column_name
      integer :: PQfnumber

      interface 
         function c_PQ_field_number(pgresult, c_name) bind(c, name='PQfnumber') &
                                                      result(res)
            import c_ptr, c_int, c_char
            implicit none
            type(c_ptr), intent(in), value :: pgresult
            character(1, kind=c_char), intent(in) :: c_name(*)
            integer(c_int) :: res
         end function c_PQ_field_number
      end interface

      c_column_name = trim(adjustl(column_name))//c_null_char

      PQfnumber = c_PQ_field_number(pgresult, c_column_name)

   end function PQfnumber
   

   
   ! function PQftable
   ! function PQftablecol
   ! function PQfformat
   ! function PQftype
   ! funciton PQfmod
   ! function PQfsize
   ! function PQbinaryTuples
  

   function PQgetvalue (pgresult, tuple_num, field_num)
      use :: character_pointer_wrapper
      use, intrinsic :: iso_c_binding
      implicit none

      type(c_ptr), intent(in) :: pgresult
      integer(c_int), intent(in) :: tuple_num, field_num
      character(:, c_char), pointer :: PQgetvalue

      interface
         ! Interface to PQgetvalue in interface/libpq/fe-exec.c:
         !
         ! char *PQgetvalue(const PGresult *res, int tup_num, int field_num)
         !
         function c_PQ_get_value (res, tup_num, field_num) &
                                           bind(c, name='PQgetvalue')
            import c_ptr, c_int
            implicit none
            type(c_ptr), intent(in), value :: res
            integer(c_int), intent(in), value :: tup_num, field_num
            type(c_ptr):: c_PQ_get_value
         end function c_PQ_get_value
      end interface
      
      ! 
      PQgetvalue => &
         c_to_f_charpointer( &
            c_PQ_get_value( pgresult, tuple_num, field_num) &
         )

   end function PQgetvalue


   function PQgetisnull (pgresult, row_number, column_number)
      use, intrinsic :: iso_c_binding
      use, intrinsic :: iso_fortran_env
      
      type(c_ptr), intent(in) :: pgresult
      integer(int32), intent(in) :: row_number, column_number
      logical :: PQgetisnull

      interface
         function c_PQ_get_is_null (res, row_number, column_number) bind(c, name="PQgetisnull")
            import c_ptr, c_int
            implicit none
            type(c_ptr), intent(in), value :: res
            integer(c_int), intent(in), value :: row_number
            integer(c_int), intent(in), value :: column_number
            integer(c_int) :: c_PQ_get_is_null
         end function c_PQ_get_is_null
      end interface

      block
         integer :: func_result

         func_result = c_PQ_get_is_null(pgresult, row_number, column_number)

         PQgetisnull = .false.

         if (func_result == 0) then 
            PQgetisnull = .false.
         
         else if (func_result == 1 ) then
            PQgetisnull = .true.
         end if
         
      end block

   end function PQgetisnull
   ! function PQgetlength
   ! function PQnparams
   ! function PQparamtype
   ! function PQprint
   

   !== Retrieving Other Result Information

   ! function PQcmdStatus
   ! function PQcmdTuples
   ! function PQoidValue
   ! function PQoidStatus
   
   
   !== Escaping Strings for Inclusion in SQL Commands

   ! function PQescapeLiteral
   ! function PQescapeIdentifier
   ! function PQescapeStringConn
   ! function PQescapeByteConn
   ! function PQunescapeBytea


   !==================================================================!
   ! Asynchronous Command Processing

   ! function PQsendQuery
   ! function PQsendQueryParams
   ! function PQsendPrepare
   ! function PQsendQueryPrepared
   ! function PQsendDescribePrepared
   ! function PQsendDescribePortal
   ! function PQgetResult
   ! function PQconsumeInput
   ! function PQisBusy
   ! function PQsetnonblocking
   ! funciton PQisnonblocking
   ! function PQflush


   !=================================================================!
   ! Pipeline Mode
   
   ! function PQpipelineStatus
   ! function PQenterPipelineMode
   ! funciton PQexitPipelineMode
   ! function PQpipelineSync
   ! function PQsendFlushRequest
   

   !=================================================================!
   ! Functions Associated with the COPY Command
   
   ! function PQputCopyData
   ! function PQputCopyEnd
   ! function PQgetCopyData


   subroutine PQfreemem(cptr)
      use, intrinsic :: iso_c_binding
      implicit none
      type(c_ptr), intent(in) :: cptr

      interface
         subroutine c_PQ_free_memory (cptr) bind(c, name="PQfreemem")
            import c_ptr
            implicit none
            type(c_ptr), intent(in), value :: cptr
         end subroutine c_PQ_free_memory
      end interface

      call c_PQ_free_memory(cptr)

   end subroutine PQfreemem 


end module m_fe_exec