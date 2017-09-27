using System;
using System.Collections.Generic;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.IO.Ports;

namespace Assign_3a
{
    public partial class Form1 : Form
    {
        SerialPort ComPort = new SerialPort();
        private const byte READ_PINA    = 0x01;
        private const byte CHECK_TX     = 0x00;
        private const byte SET_PORTC    = 0x0A;
        private const byte START_BYTE   = 0x53;
        private const byte STOP_BYTE    = 0xAA;
        private const byte TX_VALID     = 0x0F;
        public Form1()
        {
            
            InitializeComponent();
            //populate combo combox with available PORTss
            string[] ports = System.IO.Ports.SerialPort.GetPortNames();
            foreach (string port in ports)
            {
                comPort.Items.Add(port);
            }
            //Default baud rate to 38400
            baudRate.SelectedIndex = 2; 
            //Turn LED Off to start with
            ledBulb2.On = false;
            
        }

        private void Connect_Click(object sender, EventArgs e)
        {
            string Port_Name = comPort.SelectedItem.ToString();
            ComPort.PortName = Port_Name;
            ComPort.BaudRate = int.Parse(baudRate.SelectedItem.ToString());
           ComPort.DataBits = 8;               //Serial Port ComPort has 8 databits
           ComPort.Parity = 0;                 //No Parity
           ComPort.StopBits = StopBits.One;    //1 Stop bit
           ComPort.ReadTimeout = 500;          //500ms R/W timeout
           ComPort.WriteTimeout = 500;         
           ComPort.Open();                     //Open COMPORT
           //Check TX/RX, PC/MCU Handshake
           byte[] checkMCU = new byte [3] {START_BYTE, CHECK_TX, STOP_BYTE};
          ComPort.Write(checkMCU, 0, 3);
           if (ComPort.ReadByte() == TX_VALID)
           {
               ledBulb2.On = true;
               MessageBox.Show(String.Format("Connected"));
           }
           
            else
            {
                MessageBox.Show(String.Format("Error: Connection Failed"));
                ledBulb2.On = false;
            }
          
        }

        private void tabPage4_Click(object sender, EventArgs e)
        {

        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }
  
        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void baudRate_SelectedIndexChanged(object sender, EventArgs e)
        {
           
        }

        private void comPort_SelectedIndexChanged(object sender, EventArgs e)
        {
           
        }

        private void Tx_TextChanged(object sender, EventArgs e)
        {

        }

        private void textBox10_TextChanged(object sender, EventArgs e)
        {

        }

        private void ledBulb2_Click(object sender, EventArgs e)
        {

        }

       

        private void Refresh_Click(object sender, EventArgs e)
        {
   
            //checked boxes handled as int
            int ledDEC = 0;
      
            if (PC0.Checked)
                ledDEC++;
            if (PC1.Checked)
                ledDEC += 2;
            if (PC2.Checked)
                ledDEC += 4;
            if (PC3.Checked)
                ledDEC += 8;
            if (PC4.Checked)
                ledDEC += 16;
            if (PC5.Checked)
                ledDEC += 32;
            if (PC6.Checked)
                ledDEC += 64;
            if (PC7.Checked)
                ledDEC += 128;
             

            //int checked boxes converted to string for HEX value
            string LED = Convert.ToString(ledDEC, 16);
            //Display each character of the HEX code in the different displays
            if(LED.Length == 1)
            {
                LED = LED.Insert(0, "0");
            }
            sevenSegment1.Value = LED.Substring(0, 1);
            sevenSegment2.Value = LED.Substring(1, 1);

            //converting LED string hex to bytes, and formatting for TX
            byte ledDATA = Convert.ToByte(ledDEC);
            //byte array in format of (STARTBIT, INSTRUCTION BIT, TX Data, STOP BIT)
            byte[] ledTX = { START_BYTE, SET_PORTC, ledDATA, STOP_BYTE };
            //TX LEDs to MCU 
            ComPort.Write(ledTX, 0, 4);

            //TX The request to read PINA from the MCU
            byte[] readMCU = {START_BYTE, READ_PINA, STOP_BYTE};
            ComPort.DiscardInBuffer();
            ComPort.Write(readMCU,0,3);
            
            //Read the MCUs transmitted PINA Data
            byte readPINA = (byte)ComPort.ReadByte();

            //Bitwise AND to turn off the unrequired bits, then convert to boolean.
            PA0.On = Convert.ToBoolean(readPINA & 0x1);
            PA1.On = Convert.ToBoolean(readPINA & 0x2);
            PA2.On = Convert.ToBoolean(readPINA & 0x4);
            PA3.On = Convert.ToBoolean(readPINA & 0x8);
            PA4.On = Convert.ToBoolean(readPINA & 0x10);
            PA5.On = Convert.ToBoolean(readPINA & 0x20);
            PA6.On = Convert.ToBoolean(readPINA & 0x40);
            PA7.On = Convert.ToBoolean(readPINA & 0x80);
            
        }

        private void PC0_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void PC1_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void PC2_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void PC3_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void PC4_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void PC5_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void PC6_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void PC7_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void PA0_Click(object sender, EventArgs e)
        {

        }

        private void sevenSegment1_Load(object sender, EventArgs e)
        {
        
        }

        private void sevenSegment2_Load(object sender, EventArgs e)
        {

        }
      
       
    }
}
