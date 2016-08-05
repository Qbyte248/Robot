package Robot.Java;

import Robot.Java.Helper.*;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

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

public class DrawingServer extends JComponent implements CommandInterpreter {
	public static void main(String[] args) {
		System.out.println("Hello World");
		
		// FIXME: comment in
		World w = new World();
		
		
		Polygon pol = new Polygon();
		pol.append(new Vector(10, 10));
		
		Command com = new Command("testCommand");
		try {
			// !!! can throw IOExeption
			DrawingServer server = new DrawingServer();
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
	ArrayList<CommandDistributor> commandDistributors = new ArrayList<>();
	
	ArrayList<Drawable> drawables = new ArrayList<>();
	boolean alwaysRepaint = false;
	
	DrawingServer() throws IOException {
		serverSocket = new ServerSocket(1234);
		
		JFrame testFrame = new JFrame();
		testFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		//final LinesComponent comp = new LinesComponent();
		// comp == this
		// repaint() calls paintComponent()
		
		this.setPreferredSize(new Dimension(320, 200));
		testFrame.getContentPane().add(this, BorderLayout.CENTER);
		JPanel buttonsPanel = new JPanel();
		JButton newLineButton = new JButton("New Line");
		JButton clearButton = new JButton("Clear");
		clearButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent evt) {
				drawables.clear();
				repaint();
			}
		});
		buttonsPanel.add(newLineButton);
		buttonsPanel.add(clearButton);
		testFrame.getContentPane().add(buttonsPanel, BorderLayout.SOUTH);
		
		testFrame.pack();
		testFrame.setVisible(true);
	}
	
	@Override
	synchronized protected void paintComponent(Graphics g) {
		super.paintComponent(g);
		
		long startTime = System.currentTimeMillis();
		
		//int counter = 0;
		for (Drawable drawable : drawables) {
			/*counter += 1;
			float color = (float) counter / (float) drawables.size();
			g.setColor(new Color(color, 0f, 1 - color, 0.1f));*/
			
			MyColor color = drawable.getColor();
			Line line = drawable.getLine();
			Rectangle rectangle = drawable.getRectangle();
			Polygon polygon = drawable.getPolygon();
			
			if (color != null) {
				g.setColor(color.getAWTColor());
			} else if (line != null) {
				/*g.drawLine(new Line2D(
						   (int)line.start.x, (int)line.start.y,
						   (int)line.end.x, (int)line.end.y);*/
				((Graphics2D)g).draw(
					   new Line2D.Double(line.start.x, line.start.y,
									  line.end.x, line.end.y));
			} else if (rectangle != null) {
				g.fillRect((int)rectangle.origin.x, (int)rectangle.origin.y,
						   (int)rectangle.size.width, (int)rectangle.size.height);
			} else if (polygon != null) {
				int[] xs = new int[polygon.points.size()];
				int[] ys = new int[polygon.points.size()];
				for (int i = 0; i < polygon.points.size(); i += 1) {
					xs[i] = (int)polygon.points.get(i).x;
					ys[i] = (int)polygon.points.get(i).y;
				}
				g.fillPolygon(xs, ys, polygon.points.size());
			}
		}
		
		long endTime = System.currentTimeMillis();
		System.out.println(endTime - startTime);
		
	}
	
	public void accept() throws IOException {
		System.out.println("about to connect");
		System.out.println(commandDistributors.size());
		
		// !!! can throw
		Socket clientSocket = serverSocket.accept();
		
		System.out.println("connected");
		
		CommandDistributor commandDistributor = new CommandDistributor(clientSocket.getInputStream());
		commandDistributor.addCommandInterpreter(this);
		commandDistributors.add(commandDistributor);
	}
	
	// --- CommandInterpreter
	
	private <D extends Drawable & ObjectConvertible> void addDrawable(Command command, String key, D drawable) {
		Object drawableObj = new Parser(command.getParameterValueForKey(key)).object;
		if (drawableObj == null) {
			return;
		}
		
		// !!! can throw
		drawable.convertFromObject(drawableObj);
		drawables.add(drawable);
	}
	
	synchronized public void interpretCommand(Command command) {
		
		switch (command.getCommandString()) {
			case Protocol.Client.color:
				addDrawable(command, Protocol.Key.color,
							new MyColor(0,0,0,0));
				break;
			case Protocol.Client.point:
				Object pointObj = new Parser(command.getParameterValueForKey(Protocol.Key.point)).object;
				if (pointObj == null) {
					return;
				}
				Vector point = new Vector(0,0);
				// !!! can throw
				point.convertFromObject(pointObj);
				
				
				break;
			case Protocol.Client.line:
				addDrawable(command, Protocol.Key.line,
							new Line(new Vector(0,0), new Vector(0,0)));
				break;
			case Protocol.Client.rectangle:
				addDrawable(command, Protocol.Key.rectangle,
							new Rectangle(0,0,0,0));
				break;
			case Protocol.Client.polygon:
				addDrawable(command, Protocol.Key.polygon,
							new Polygon());
				break;
				
			case Protocol.Client.clear:
				drawables.clear();
				break;
			case Protocol.Client.repaint:
				String alwaysString = command.getParameterValueForKey(Protocol.Key.always);
				if (alwaysString == null) {
					this.repaint();
					// return in order to repaint only once
					return;
				}
				
				try {
					this.alwaysRepaint = Boolean.parseBoolean(alwaysString);
				} catch (Exception e) {}
		}
		
		if (alwaysRepaint) {
			this.repaint();
		}
	}
	
	public boolean finishedInterpretingCommands() {
		return false;
	}
}
