import processing.serial.*;

Serial arduino;
SerialMenu menu;
int numData = 3;  // quantidade de dados
float valor1, valor2, valor3;  // dados
float[] data, dataCheck;  // vetor de dados e vetor auxiliar para debug
boolean inMenu = true;

//========================================MAIN SETUP========================================//

void setup()
{
  size(640, 480);
  //fullScreen();
  rectMode(CENTER);

  data = new float[numData];
  dataCheck = new float[numData];
}

//========================================MAIN LOOP========================================//

void draw()
{
  background(0);
  textAlign(CENTER);

  if (inMenu)
  {
    //inicia um menu com a quantidade com o nome das portas serias
    menu = new SerialMenu(Serial.list().length, Serial.list());
    menu.Display();  //mostra o menu
    //verifica se a porta ta conectada
    if (menu.PortConnected[menu.PortSelected]) 
    {
      //evita portas ocupadas ou inexistentes
      try
      {
        //inicia um serial com a porta selecionada no menu
        arduino = new Serial(this, Serial.list()[menu.PortSelected], 9600);
        arduino.bufferUntil('\n');
        delay(100);
        inMenu = false;
      }
      catch (Exception e)
      {
        //em caso de erro
        textAlign(CENTER);
        textSize(20);
        text("COM port is not available", width/2, 0.8*height);
        text("Error da Porta: " + e, width/2, 0.9*height);
      }
    }
  } else
  {
    // programa rodando com os dados recebidos
    valor1 = dataCheck[0];
    valor2 = dataCheck[1];
    valor3 = dataCheck[2];  // atribuicao livre de erros
    print(valor1);
    print("\t");
    print(valor2);
    print("\t");
    println(valor3);
  }
}

//========================================SERIAL LOOP========================================//

void serialEvent(Serial s)
{
  if (s.available() > 0)
  {
    String inString = s.readStringUntil('\n');
    if (inString != null)
    {
      inString = trim(inString);
      data = float(split(inString, '_'));
      for (int i = 0; i < numData; i++)
      {
        //evita que cada valor nao receba nada ou que exceda o limite da variavel 
        try
        { 
          dataCheck[i] = data[i];  // atribuicao que pode dar erro
        }
        catch (Exception e)
        {
          println("Erro de Dados: " + e);
          dataCheck[i] = 0;  // em caso de erro, zera o valor 
        }
      }
    }
  }
}

//========================================BUTTON CLASS========================================//

class Button
{
  PVector Pos, Size;
  String Text;
  color TxtColor = color(250);
  color BG = color(140);
  color BG_Press = color(180);

  Button(String txt, int x, int y, int w, int h)  // text, position and rectangule sizes
  {
    Pos = new PVector(x, y);
    Size = new PVector(w, h);
    Text = txt;
  }


  boolean MouseOn(int x, int y)  // verifies if the mouse is on the button
  {
    if (x >= Pos.x - Size.x/2 && x <= Pos.x + Size.x/2)
      if (y <= Pos.y + Size.y/2 && y >= Pos.y - Size.y/2)
        return true;

    return false;
  }

  boolean Pressed()  // verifies if the button if pressed
  {
    if (mousePressed && MouseOn(mouseX, mouseY))
      return true;
    else
      return false;
  }

  void Display()  // shows the button
  {
    noStroke();

    if (MouseOn(mouseX, mouseY))
      fill(BG_Press);
    else
      fill(BG);

    rect(Pos.x, Pos.y, Size.x, Size.y);

    if (Size.x > Size.y)
      textSize(Size.y/4);
    else
      textSize(Size.x/4);

    fill(TxtColor);
    textAlign(CENTER, CENTER);
    text(Text, Pos.x, Pos.y);
    //textAlign(RIGHT, BOTTOM);
  }
}

//========================================MENU CLASS========================================//

class SerialMenu
{
  Button[] buttonCOM;
  String[] PortName;
  String tag;
  int NumPort, PortSelected;
  boolean[] PortConnected;
  color TextColor = color(255);

  SerialMenu(int ports, String[] names)  // number of ports and these names
  {
    NumPort = ports;
    PortName = new String[ports];
    PortConnected = new boolean[ports];
    buttonCOM = new Button[ports];

    for (byte i = 0; i < ports; i++)
    {
      PortName[i] = names[i];
      buttonCOM[i] = new Button(names[i], (i+1)*width/(ports+1), 50+height/2, 120, 80);
    }
  }


  void Display()  // shows menu
  {
    background(55);

    textSize(width/25);
    text("Portas Seriais", width/2, 100);

    for (byte i = 0; i < NumPort; i++)
    {
      buttonCOM[i].Display();
      if (buttonCOM[i].Pressed())
      {
        PortSelected = i;
        PortConnected[i] = true;
      }
    }
  }
}
