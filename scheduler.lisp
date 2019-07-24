(defpackage #:scheduler
  (:use :cl))
(in-package #:scheduler)

;;;;https://en.wikipedia.org/wiki/Completely_Fair_Scheduler
;;;;https://www.linuxjournal.com/node/10267
;;;;how to sort tasks? giorgio in the loop sorting?

(struct-to-clos:struct->class 
 (defstruct task
   weight
   (wait-time 0)))
(defun print-task (stream task)
  (format stream
	  #+nil
	  "<task: mass: ~a internal: ~a time: ~2$>"
	  ;;"<~6,' d , ~2$ , ~2$>"
	  "<~6,' d , ~2$>"
	  (task-weight task)
	  (/ (task-wait-time task)
	     (task-weight task))
	  ;;(task-wait-time task)
	  ))
(set-pprint-dispatch 'task 'print-task)

(progn
  ;;(defparameter *global-clock* 0)
  (defparameter *tasks-total-weight* 0)
  ;;(defparameter *tasks-average-weight* 0)
  (defparameter *tasks* nil)
  (defparameter *tasks-dirty* nil)
  (defparameter *task-count* 0)
  (defun add-task (task)
    ;;(timestep (- (task-wait-time task)))
    (let ((old-weight (tasks-total-weight))
	  (old-tasks *tasks*))
      (pushnew task *tasks* :test 'eq)
      (let ((new-weight (tasks-total-weight)))
	(when old-tasks ;;recompute wait times...?
	  (re-time-tasks old-weight new-weight))))
    
    (calculate-info)
    ;;(normalize-wait-times)
    (setf *tasks-dirty* t))
  (defun remove-task (task)
    (let ((old-weight (tasks-total-weight)))
      (setf *tasks* (delete task *tasks*))
      (let ((new-weight (tasks-total-weight)))
	(re-time-tasks old-weight new-weight)
	))
    (calculate-info)
    ;;normalize wait times
    ;;(normalize-wait-times)
    (setf *tasks-dirty* t)))

(defun divide (x new-weight old-weight)
  ;;we multiply two fixnums in order to preserve information.
  ;;the ceiling function makes sure tasks don't get rounded...?

  ;;biggest fear: process starvation due to rounding errors?
  (floor (* x new-weight) old-weight))
(defun re-time-tasks (old-weight new-weight)
  ;;a task removed from the system has time remaining. The time is liquidated.
  ;;(timestep (task-wait-time task))
  (mapc
   (lambda (task)
     (setf (task-wait-time task)
	   (divide (task-wait-time task)
		   new-weight
		   old-weight)))
   *tasks*
   ))

(defun remove-task-number (&optional (n 0))
  (remove-task (elt *tasks* n)))

(defun normalize-wait-times ()
  "make sure that the sum of the tasks total time remains bounded."
  (let ((total (tasks-total-time)))
    (timestep (floor total *tasks-total-weight*))))

(defun reset-tasks ()
  (setf *tasks* nil)
  (setf *tasks-dirty* t))

(defun print-tasks (&optional (tasks *tasks*))
  (print (tasks-total-time))
  ;;(format t "~%clock: ~3$" *global-clock*)
  (dolist (task tasks)
    (print task))
  (format t
	  "~% ~2$"
	  (/ (tasks-total-time)
	     *tasks-total-weight*))
  (values))

(defun tasks-total-weight ()
  (reduce '+ *tasks* :key 'task-weight))
(defun task-count ()
  (length *tasks*))
(defun calculate-info ()
  (setf *tasks-total-weight* (tasks-total-weight))
  (setf *task-count* (task-count))
  #+nil
  (setf *tasks-average-weight*
	(utility:floatify
	 ;;FIXME::using floats is faster, but not accurate.
	 ;;A task with really small priority might never get attention due to rounding errors.
	 ;;using rational numbers for task priorities and waits is correct, but i'm
	 ;;afraid it will blow up or something. How could this happen? 
	 (/ *tasks-total-weight*
	    *task-count*))))

(defun compare-expected-wait-times (task-a task-b)
  (let ((weight-a 
	 (task-weight task-a))
	(weight-b 
	 (task-weight task-b)))
    (let ((foo-a
	   (* weight-a
	      (task-wait-time task-b)))
	  (foo-b
	   (* weight-b
	      (task-wait-time task-a))))
      (if (= foo-a foo-b)
	  (> weight-a weight-b)
	  (> foo-a foo-b)))))
(defun sort-tasks (&optional (force nil))
  "ensure tasks are sorted according to waiting time. 
when force is T, sort the tasks no matter what"
  (when (or force
	    *tasks-dirty*)
    (setf *tasks*
	  (sort *tasks*
		'compare-expected-wait-times)))
  (setf *tasks-dirty* nil)
  (values))

#+nil
(defun relative-weight-to-whole (task)
  (/ (task-weight task)
     *tasks-total-weight*))

(defun timestep (n-steps)
  (setf *tasks-dirty* t)
  ;;(incf *global-clock* n-steps)
  (mapc
   (lambda (task)
     (decf (task-wait-time task)
	   (* n-steps
	      (task-weight task)
	      #+nil
	      (relative-weight-to-whole task)))
     #+nil
     (setf (task-expected-wait-time task)
	   (/ (task-wait-time task)
	      (task-weight task)))
     #+nil
     (decf (task-expected-wait-time task)))
   *tasks*))

(defun easy-make-task (weight)
  (let ((task
	 (make-task :weight weight)))
    (add-task task)
    task))

(defparameter *sample-tasks*
  #+nil
  '(1 2 7 20)
					;'(1 3)
  '(1 3 1 3 5 8))
(defun what ()
  (mapcar
   (lambda (x)
     (easy-make-task x)
     ;;(print-tasks)
     )
   *sample-tasks*))

(defun timestep-and-sort (&optional (n 1))
  (timestep n)
  (sort-tasks)
  (values))

(defun most-waited-task ()
  (sort-tasks)
  (first *tasks*))

(defun scheduloop (&optional (n 10))
  ;; (timestep-and-sort) ;;initialize? is this necessary?
  (dotimes (x n)
    (terpri)
    (one-step)
    (print-tasks)))

(defun one-step ()
  (let ((first-task (most-waited-task)))
    (let ((time-elapsed *tasks-total-weight*))
      (progn
	(incf (task-wait-time first-task)
	      time-elapsed)
	(calculate-info))
      (timestep-and-sort
       1;time-elapsed
       ))))

(defun nice-one-step ()
  (one-step)
  (print-tasks))

(defun tasks-total-time ()
  (reduce '+ *tasks* :key 'task-wait-time))

;;;;
(defun a-random (n)
  (1+ (random (ash 1 (random n)))))
(defun a-random2 (n)
  (1+ (random n)))
(defun test69 ()
  (dotimes (x 100)
    (easy-make-task (a-random2 4000000))
    (dotimes (x (random 10))
      (one-step)
      #+nil
      (nice-one-step))
    (remove-task-number (random (task-count)))))
;;;;I can't figure out if the floor function would cause
;;;;the timers to grow without bound. It's random?
;;;;just test and see? my skin is in the game?
