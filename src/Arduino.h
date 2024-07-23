/* NetBurner "Arduino Compatibility" Shim
 *
 * This file is hand-written by NetBurner to wrap NetBurner
 * functions with Arduino-compatible names to more easily
 * integrate third-party libraries. It contains no Arduino
 * or GPL-licensed source code. Arduino is a trademark of
 * Arduino S.A. and is not affiliated with NetBurner.
 *
 * This file is released without copyright,  and
 * NetBurner makes no representation or warranties with respect to the
 * performance of this computer program, and specifically disclaims any
 * responsibility for any damages, special or consequential, connected with
 * the use of this program.
 */

#ifndef _NB_ARDUINO
#define _NB_ARDUINO

#include <nbstring.h>
#include <stdio.h>
#include <string.h>
#include <serial.h>
#include <nbprintfinternal.h>
#include <stdarg.h>
#include <math.h>

typedef bool boolean;
typedef uint8_t byte;

#define PI 3.1415926535

static inline void delay(int x) 
{
	if (x > (1000/TICKS_PER_SECOND)) { OSTimeDly(x/TICKS_PER_SECOND+1); } 
	 else for (volatile int i = 0; i < x*100000; i++);
}
static inline int min(const int a, const int b) {
	return a < b ? a : b;
}
static inline int max(const int a, const int b) {
	return a > b ? a : b;
}
static inline long map(long x, long in_min, long in_max, long out_min, long out_max)
{
	long outD = (out_max - out_min);
	long inR = (x - in_min);
	long inD = (in_max - in_min);
	return outD*inR/inD+out_min;
}
static inline unsigned long millis() {
	return Secs*1000;
}

class String : public NBString
{
public:
		String(){};

		/**
		 * @brief Construct a new NBString object from an existing NBString object
		 *
		 * @param str   Existing NBString object
		 */
		String(const NBString &str) :NBString(str) {};
		

		/**
		 * @brief Construct a new NBString object from a substring of an existing NBString object.
		 *
		 * @param str   Existing NBString object
		 * @param pos   Starting position to copy
		 * @param len   Ending position to copy
		 */
		String(const NBString &str, size_t pos, size_t len = npos) :NBString(str,pos,len) {};

		/**
		 * @brief Construct a NBString object from a character string (null terminated array of characters)
		 *
		 * @param s   String to initialize object
		 */
		String(const char *s) :NBString(s) {};
		

		/**
		 * @brief Construct a NBString object from a character string up to the specified amount
		 *
		 * @param s     String to initialize object
		 * @param n     Number of characters to copy
		 */
		String(const char *s, size_t n) : NBString(s,n){};

		String(uint32_t v) {siprintf("%lu",v); };
		String(uint16_t v) {siprintf("%u",v); };
		String(uint8_t v) {siprintf("%u",v); };
		String(int32_t v) {siprintf("%ld",v); };
		String(int16_t v) {siprintf("%d",v); };

};


#define HEX (16)
#define DEC (10)
#define OCT (8)
#define BIN (2)


class Print
{
size_t  handle_unum(uint32_t v, int base)
{
NBString s;
switch(base)
{
case 16: s.siprintf("%lX",v); break;
case 10: s.siprintf("%ld",v); break; 
case 8: s.siprintf("%lo",v); break; 
case 2: s.siprintf("%b",v); break; 
default:return 0;
}
return print((const NBString)s); // (uint8_t *)s.c_str(),s.length()
}

size_t  handle_inum(int32_t v, int base)
{
if(v<0)
{
return write((uint8_t)'-')+handle_unum((uint32_t)-v,base); 
}
return handle_unum((uint32_t)v,base);
}

public:
virtual size_t write(uint8_t c)=0; // Pure virtual, must be implemented precisely by children

virtual size_t write(const uint8_t *buffer, size_t size=0){ size_t i=0; while(i<size) { write((uint8_t)buffer[i]); i++; } return i; };
virtual size_t write(const char *str) {if(str) {return write((uint8_t *)str,strlen(str));} return 0; };


inline size_t print(const char *c) {if(c) return write(c); else return 0;};

inline size_t print(const NBString & s){ return write(s.c_str());}

inline size_t print(char c) { return write((uint8_t *)&c,1);};

inline size_t print(uint32_t i,int base=10){ return handle_unum(i,base);}

inline size_t print(int32_t i,int base=10){ return handle_inum(i,base);} 

inline size_t print(int i,int base=10){ return handle_inum((int32_t)i,base);};  

//inline size_t print(long i,int base=10){ return handle_inum((int32_t)i,base);};

inline size_t print(unsigned int i,int base=10){ return handle_unum((uint32_t)i,base);}; 

inline size_t print(unsigned char i,int base=10){ return handle_unum((uint32_t)i,base);}; 

//inline size_t print(unsigned long i,int base=10){ return handle_unum((uint32_t)i,base);}; 

inline size_t print(double d, int wid=2) {NBString s; s.sprintf("%0.*f",wid,d); return write((uint8_t *)s.c_str(),s.length()); };


inline size_t print(float f, int wid=2){ return print((double)f,wid);};

inline size_t println(const char *c) {int rv=print(c); rv+=write((uint8_t *)"\r\n",2); return rv;};

inline size_t println(const NBString & s) {int rv=print(s); rv+=write((uint8_t *)"\r\n",2); return rv;}; 

inline size_t println(char c) {int rv=print(c); rv+=write((uint8_t *)"\r\n",2); return rv;}; 

inline size_t println(int i,int base =10) {int rv=print(i,base); rv+=write((uint8_t *)"\r\n",2); return rv;}; 

inline size_t println(unsigned int i,int base=10) {int rv=print(i,base); rv+=write((uint8_t *)"\r\n",2); return rv;};  

inline size_t println(unsigned char i,int base=10){int rv=print(i,base); rv+=write((uint8_t *)"\r\n",2); return rv;};  

inline size_t println(unsigned long i,int base=10){int rv=print(i,base); rv+=write((uint8_t *)"\r\n",2); return rv;};  

inline size_t println(long i,int base=10) {int rv=print(i,base); rv+=write((uint8_t *)"\r\n",2); return rv;};  

inline size_t println(double d,int wid=2){int rv=print(d,wid); rv+=write((uint8_t *)"\r\n",2); return rv;}; 

inline size_t println(float f, int wid=2) {int rv=print(f,wid); rv+=write((uint8_t *)"\r\n",2); return rv;}; 
inline size_t println() {return write((uint8_t *)"\r\n",2);}; 
};


class  FDprint : public Print
{
int m_fd;
public:
virtual size_t write(uint8_t c) { char o[1]; o[0] = c; return ::write(m_fd,(const char*)o, 1);};
FDprint(int fd) {m_fd=fd; };
};


 
 
#define 	pgm_read_byte_near(address_short)   *((uint8_t*)(address_short))
 
#define 	pgm_read_word_near(address_short)   *((uint16_t*)(address_short))
 
#define 	pgm_read_dword_near(address_short)   *((uint32_t*)(address_short))
 
#define 	pgm_read_float_near(address_short)   *((float *)(address_short))
 
 

class SerialIf : public FDprint
{
public:
inline int begin(int b){SerialClose(0); return SimpleOpenSerial(0, b);};
SerialIf() : FDprint(0) {};
};

extern SerialIf Serial;

#endif

