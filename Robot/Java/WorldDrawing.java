package Robot.Java;

import Robot.Java.Helper.*;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.LinkedList;

import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JPanel;

import java.awt.geom.Line2D;
import java.awt.Graphics2D;

public class WorldDrawing extends JComponent implements CommandInterpreter {
	public static void main(String[] args) {
		System.out.println("Hello World");
		
		// FIXME: comment in
		World w = new World();
		
		
		Polygon pol = new Polygon();
		pol.append(new Vector(10, 10));
		
		Command com = new Command("testCommand");
		try {
			// !!! can throw IOExeption
			WorldDrawing server = new WorldDrawing();
			while (true) {
				try {
					// !!! can throw IOExeption
					server.accept();
				} catch (IOException e) {
					System.out.println("could not connect to client");
				}
			}
		} catch (IOException e) {
			System.out.println("Exception occured");
		}

	}
	
	ServerSocket serverSocket;
	// FIXME: probably only one distributor allowed
	CommandDistributor commandDistributor;
	
	ArrayList<World> worlds = new ArrayList<>();
	World currentWorld = null;
	
	WorldDrawing() throws IOException {
		serverSocket = new ServerSocket(1234);
		
		JFrame testFrame = new JFrame();
		testFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		//final LinesComponent comp = new LinesComponent();
		// comp == this
		// repaint() calls paintComponent()
		
		this.setPreferredSize(new Dimension(320, 200));
		testFrame.setLocation(100, 100);
		
		testFrame.getContentPane().add(this, BorderLayout.CENTER);
		JPanel buttonsPanel = new JPanel();
		testFrame.getContentPane().add(buttonsPanel, BorderLayout.SOUTH);
		
		testFrame.pack();
		testFrame.setVisible(true);
	}
	
	@Override
	synchronized protected void paintComponent(Graphics g) {
		super.paintComponent(g);
		
		long startTime = System.currentTimeMillis();
		
		if (currentWorld != null) {
			currentWorld.drawOnGraphics(g, new Vector(10, this.getHeight()));
		}
		
		long endTime = System.currentTimeMillis();
		System.out.println(endTime - startTime);
		
	}
	
	public void accept() throws IOException {
		System.out.println("about to connect");
		
		// !!! can throw
		Socket clientSocket = serverSocket.accept();
		
		System.out.println("connected");
		
		// clear worlds and reset timer
		worlds.clear();
		timer.cancel();
		timer = new Timer();
		
		if (this.commandDistributor != null) {
			this.commandDistributor.stopThread();
		}
		this.commandDistributor = new CommandDistributor(clientSocket.getInputStream());
		commandDistributor.addCommandInterpreter(this);
	}
	
	Timer timer = new Timer();
	double frameTime = 0.1;
	
	public void run() {
		WorldDrawing worldDrawing = this;
		
		int i = 0;
		for (World world : worlds) {
			timer.schedule(new TimerTask() {
				public void run() {
					currentWorld = world;
					worldDrawing.repaint();
				}
			}, (long)(frameTime * 1000 * i));
			i += 1;
			/*try {
				Thread.sleep(1000);
			} catch (Exception e) {}*/
		}
	}
	
	// --- CommandInterpreter
	
	synchronized public void interpretCommand(Command command) {
		
		switch (command.getCommandString()) {
			case Protocol.Client.world:
				Object worldObject = new Parser(command.getParameterValueForKey(Protocol.Key.world)).object;
				
				World world = new World();
				world.convertFromObject(worldObject);
				worlds.add(world);
				
				break;
			case Protocol.Client.run:
				
				Object frameTimeObject = command.getParameterValueForKey(Protocol.Key.frameTime);
				
				if (frameTimeObject != null) {
					String frameTimeString = Helper.castToString(frameTimeObject);
					try {
						// !!! can throw
						this.frameTime = Double.parseDouble(frameTimeString);
					} catch (Exception e) {
						throw new IllegalArgumentException("could not convert string (" + frameTimeString + ") to number");
					}
				}
				this.run();
				break;
			default: break;
		}
	}
	
	public boolean finishedInterpretingCommands() {
		return false;
	}
}
