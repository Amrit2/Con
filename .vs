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
      private EventHandler ev;// no clue what this is for, might or might not need it
      private AppBoard board = new AppBoard();

        SerialPort ComPort = new SerialPort();
        public Form1()
        {

            InitializeComponent();
            string[] ports = System.IO.Ports.SerialPort.GetPortNames();
            foreach (string port in ports)
            {
                comPort.Items.Add(port);
            }

            baudRate.SelectedIndex = 2; // DEFAULTING to 38400
            ledBulb2.On = false;

        }

        private void Connect_Click(object sender, EventArgs e)
        {


            //SerialPort ComPort = new SerialPort();          //Serial Comms name is ComPort, different to comPort (we might want to change this name)
            //ComPort.PortName = Convert.ToString(comPort.text);
            //comPort.text = ports[0];

            string Port_Name = comPort.SelectedItem.ToString();

            ComPort.PortName = Port_Name;


            ComPort.DataBits = 8;           //Serial Port ComPort has 8 databits
            ComPort.Parity = 0;               //No Parity
            ComPort.StopBits = StopBits.One;         //1 Stop bit
            ComPort.ReadTimeout = 500;        //500ms timeout
            ComPort.WriteTimeout = 500;


            //ComPort.Open();

            if (ComPort.IsOpen == true)
            {
                ledBulb2.On = true;
                MessageBox.Show(String.Format("Connected"));
            }

            else
            {
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
            bool[] onLed = { PC0.Checked, PC1.Checked, PC2.Checked, PC3.Checked, PC4.Checked, PC5.Checked, PC6.Checked, PC7.Checked };
            BitArray pcLed = new BitArray(onLed);
            byte[] led = new byte [1];
            pcLed.CopyTo(led, 0);

            string str_led1 = BitConverter.ToString(led);
            sevenSegment1.Value = str_led1.Substring(0, 1);
            sevenSegment2.Value = str_led1.Substring(1, 1);

            ComPort.Open();
            ComPort.Write(str_led1);
            ComPort.Close();


            //added PINA stuff below
            board.ReadPINA();
            ByteToLEDs(board.PINA);
        }

        // GUI: Turn on LEDs based on received byte
        private void ByteToLEDs(byte receivedByte)
        {
            // BitMap/Array enables individual bit selection of received byte
            BitArray receivedBitArray = new BitArray(new byte[] { receivedByte });

            // Enable/Disable LEDs
            ledPA0.On = receivedBitArray.Get(0);
            ledPA1.On = receivedBitArray.Get(1);
            ledPA2.On = receivedBitArray.Get(2);
            ledPA3.On = receivedBitArray.Get(3);
            ledPA4.On = receivedBitArray.Get(4);
            ledPA5.On = receivedBitArray.Get(5);
            ledPA6.On = receivedBitArray.Get(6);
            ledPA7.On = receivedBitArray.Get(7);
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

        public enum ValuePattern
        {
            None = 0x0, Zero = 0x77, One = 0x24, Two = 0x5D, Three = 0x6D,
            Four = 0x2E, Five = 0x6B, Six = 0x7B, Seven = 0x25,
            Eight = 0x7F, Nine = 0x6F, A = 0x3F, B = 0x7A, C = 0x53,
            D = 0x7C, E = 0x5B, F = 0x1B, G = 0x73, H = 0x3E,
            J = 0x74, L = 0x52, N = 0x38, O = 0x78,
            P = 0x1F, Q = 0x2F, R = 0x18,
            T = 0x5A, U = 0x76, Y = 0x6E,
            Dash = 0x8, Equals = 0x48
        }


    }
}
///// make an AppBoard.cs file and include the below code/////<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// should look something like the following
using System;
using System.Collections;
using System.IO.Ports;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Security.Policy;
using System.Text;
using System.Threading.Tasks;

namespace AppBoardControl
{
    class AppBoard
    {
      private const byte TXCHECK = 0x00;
      private const byte READ_PINA = 0x01;
      private const byte START_BYTE = 0x53;
      private const byte STOP_BYTE = 0xAA;
      private const byte TX_VALID = 0x0F;

      public byte PINA;

      public void ReadPINA()
       {
           PINA = ReadUInt8(READ_PINA);
          // Debug.WriteLine("AppBoard.ReadPINA() 0x" + PINA.ToString("X2")); don't need this I think
       }
       // Write to PORTC -- below might be important not sure
        public byte WritePORTC(byte PORTC)
               {
                   byte returnValue = WriteUInt16(SET_PORTC, Convert.ToUInt16(PORTC));

                   Debug.WriteLine("AppBoard.WritePORTC() 0x" + PORTC.ToString("X2") + " [0x" + returnValue.ToString("X2") + "]");

                   return returnValue;
               }
        private byte ReadUInt8(byte instruction)
               {
                   byte[] message = {START_BYTE, instruction, STOP_BYTE};
                   _serialPort.Write(message, 0, message.Length);

                   return Convert.ToByte(_serialPort.ReadByte());
               }
               // Sends instruction + data to write, returns received byte
        private byte WriteUInt16(byte instruction, UInt16 data)
               {
                   byte[] message = { START_BYTE, instruction, (byte)(data & 0xFF), (byte)(data >> 8), STOP_BYTE };
                   _serialPort.Write(message, 0, message.Length);

                   return Convert.ToByte(_serialPort.ReadByte());
               }

      /* might need to add the following if we are to shift everything to this file but I think lets ignore it for now?
      private SerialPort _serialPort;
      public bool isConnected;
      public AppBoard()
        {
            isConnected = false;

            // Serial Port - 8N1 with 500 mS timeout
            _serialPort = new SerialPort();
            _serialPort.DataBits = 8;
            _serialPort.Parity = Parity.None;
            _serialPort.StopBits = StopBits.One;
            _serialPort.ReadTimeout = 500;
            _serialPort.WriteTimeout = 500;
        }
        // Connect to Serial Port
        public void Connect()
        {
            //if (_serialPort.BaudRate.ToString().Length == 0)
            //{
            //    throw new Exception("Baud rate not set.");
            //}

            //if (_serialPort.PortName.Length == 0)
            //{
            //    throw  new Exception("Port name not set.");
            //}

            //if (isConnected)
            //{
            //    throw new Exception("Serial Port is already connected.");
            //}

            _serialPort.Open();
        }
        // Disconnect from Serial Port
        public void Disconnect()
        {
            //if (!isConnected)
            //{
            //    throw new Exception("Board isn't even connected.");
            //}

            _serialPort.Close();
        }
        // Return available COM Ports
        public string[] GetCOMPorts()
        {
            // Sort portnames in ascending order before returning
            ArrayList portList = new ArrayList(SerialPort.GetPortNames());
            portList.Sort();
            return (string[])portList.ToArray(typeof(string));
        }
        // Set COM Port
        public void SetCOMPort(string comPort)
        {
            _serialPort.PortName = comPort;
        }
        // Set Baud Rate
        public void SetBaudRate(int baudRate)
        {
            _serialPort.BaudRate = baudRate;
        }
        // Check communications with AppBoard
        public bool CheckTx()
        {
            byte txResult = ReadUInt8(TXCHECK);

            Debug.WriteLine("AppBoard.CheckTX() 0x" + txResult.ToString("X2"));

            if (txResult == TX_VALID)
            {
                return true;
            }

            return false;
        }


      */
