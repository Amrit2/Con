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
