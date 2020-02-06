<?php
/**
 * log.php
 *
 * Logging class 
 *
 * Usage:
 * $log = new Log('/path/to/logs',Log::INFO);
 * $log->log_fatal('message');                  // logs a fatal message
 * $log->log_error('message');                  // logs an error message
 * $log->log_warn('message');                   // logs a warning message
 * $log->log_info('message');                   // logs infomational messages
 * $log->log_debug('message');                  // logs debugging messages
 * $log->log_query('message');                  // logs queries
 *  
 * @package     wayne-oliver/log
 * @author      Wayne Oliver <wayne@open-is.co.za>
 * @copyright   Wayne Oliver <wayne@open-is.co.za> 
 * @license     BSD
 ********************************** 80 Columns *********************************
 **/

// namespace Log;

class Log 
{
	/**
	* Log Level
	**/
	const FATAL = 1;    // Fatal: Application unstable unusable
	const ERROR = 2;    // Error: error conditions exist
	const WARN  = 3;    // Warning: warning conditions
	const INFO  = 4;    // Info: information messages
	const DEBUG = 5;    // Debug: debug messages
	const QUERY = 6;    // Query: log queries too
	const NONE  = 0;    // No Logging
    
	/**
	* Defaults
	**/
	private $log_file      = 'logfile.log';
	private $file_handle   = null;
	private $log_verbosity = self::INFO; 
    
	/**
	* Class constructor
	* @param string $log_dir File path to the logging directory
	* @param integer $log_level One of the pre-defined log level constants
	* @return void
	**/    
	public function __construct($log_dir='/tmp/', $log_level=self::INFO)
	{
		// Today's date
		$today = date("Y-m-d", time());
		$ds = DIRECTORY_SEPARATOR;
		
		$log_directory = rtrim($log_dir, '\\/');
		
		// Set the full path to the log file
		$this->log_file = $log_directory . $ds . "log_$today.log";
		
		// Set log Verbosity
		$this->log_verbosity = $log_level;

		// Try open the log file for appending
		if (!$this->file_handle = fopen($this->log_file, 'a')) {
			error_log(" Error opening file for logging: " . $this->log_file);
		}
	}
    
	/**
	* Class destructor 
	**/
	public function __destruct() 
	{
		// Close the file if it exists
		if ($this->file_handle) {
			fclose($this->file_handle);
		}   
	}

	/**
	* Log wrappers deprecated
	**/
	public function log_fatal($line)
	{
		$this->log($line, self::FATAL);
	}    
	public function log_error($line)
	{
		$this->log($line, self::ERROR);
	}    
	public function log_warn($line)
	{
		$this->log($line, self::WARN);
	}     
	public function log_info($line)	{
		$this->log($line, self::INFO);
	}        
	public function log_debug($line)
	{
		$this->log($line, self::DEBUG);
	}    
	public function log_query($line)
	{
		$this->log($line, self::QUERY);
	}  


	public function logFatal($line)
	{
		$this->log($line, self::FATAL);
	}    
	public function logError($line)
	{
		$this->log($line, self::ERROR);
	}    
	public function logWarn($line) 
	{
		$this->log($line, self::WARN);
	}     
	public function logInfo($line)
	{
		$this->log($line, self::INFO);
	}        
	public function logDebug($line)
	{
		$this->log($line, self::DEBUG);
	}    
	public function logQuery($line)
	{
		$this->log($line, self::QUERY);
	}  
   
	/**
	* Write the log entry 
	**/
	private function log($line, $log_level) 
	{
		// Write all events less than log verbosity
		if ($log_level <= $this->log_verbosity) {
			$line = $this->prepend($log_level) . $line . "\n";
			$this->writeLine($line);
		}
	}
    
	// write the line to the log file
	private function writeLine($line)
	{
		fwrite($this->file_handle, $line);
	}
    
	// format the line prefix
	private function prepend($log_level) 
	{
		$time = date('Y-m-d G:i:s');

		switch ($log_level) {
			
			case self::FATAL:
				return $time . ' - FATAL - ';
				break;

			case self::ERROR:
				return $time . ' - ERROR - ';
				break;

			case self::WARN:
				return $time . ' - WARN  - ';
				break;

			case self::INFO:
				return $time . ' - INFO  - ';
				break;

			case self::DEBUG:
				return $time . ' - DEBUG - ';
				break;

			case self::QUERY:
				return $time . ' - QUERY - ';
				break;

			default:
				return $time . ' - LOG   - ';
		} 
	}
}