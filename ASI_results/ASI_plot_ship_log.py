import matplotlib.pyplot as plt
import os
import datetime
import time

nthValue = 5
plotFig = True

#script_path = os.path.dirname(os.path.realpath(__file__))
log_file = r"log_rj.log"

    

class LogFileParser:
    def __init__(self, log_file):
        self.log_file = log_file
        self.last_load_step = -1  # Initialize last load step
        self.load_steps = []
        self.energies = {'elastic': [], 'plastic': [], 'el+ki+di': [], 'ext.work': []}
        self.load_step = 0
        self.load_level = 0
        self.fig = None
        self.ax1 = None
        if plotFig:
            self.create_fig()

    def parse_log_file(self):
        with open(self.log_file, 'r') as file:
            for line in file:
                if line.startswith('    1'):
                    parts = line.split()
                    try:
                        self.load_step = int(parts[1])
                        if self.load_step <= self.last_load_step:
                            continue  # Skip if load step hasn't changed
                        self.last_load_step = self.load_step

                        self.load_level = float(parts[5])

                        energy_elastic = float(parts[9])
                        energy_plastic = float(parts[10])
                        energy_total = float(parts[11])
                        energy_ext_work = float(parts[12])

                        self.load_steps.append(self.load_step)
                        self.energies['elastic'].append(energy_elastic)
                        self.energies['plastic'].append(energy_plastic)
                        self.energies['el+ki+di'].append(energy_total)
                        self.energies['ext.work'].append(energy_ext_work)
                    except (ValueError, IndexError):
                        # Ignore lines that cannot be parsed or indexed
                        continue

    def create_fig(self):
        self.fig, self.ax1 = plt.subplots(figsize=(10, 6))
        plt.ion()  # Turn on interactive mode
        self.plot_data()

    def plot_data(self):
        self.ax1.clear()  # Clear the existing plot
        load_steps_to_plot = self.load_steps[::nthValue]  # Plot every nth load step
        elastic_to_plot = self.energies['elastic'][::nthValue]
        plastic_to_plot = self.energies['plastic'][::nthValue]
        el_ki_di_to_plot = self.energies['el+ki+di'][::nthValue]
        ext_work_to_plot = self.energies['ext.work'][::nthValue]
        
        self.ax1.plot(load_steps_to_plot, elastic_to_plot, label='Elastic')
        self.ax1.plot(load_steps_to_plot, plastic_to_plot, label='Plastic')
        self.ax1.plot(load_steps_to_plot, el_ki_di_to_plot, label='Elastic + Plastic + Kinetic + Damping')
        self.ax1.plot(load_steps_to_plot, ext_work_to_plot, label='External Work')
        self.ax1.set_xlabel('Load Step')
        self.ax1.set_ylabel('Energies (kNm)')
        self.ax1.set_title('ASI Energies over Load Step')
        self.ax1.legend()
        self.ax1.grid(True)

        # Add the text with the time of update
        current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.ax1.text(0.5, -0.1, f"Updated: {current_time} / Last load-step: {self.load_step} / Last load-level: {round(self.load_level,1)}",
                 horizontalalignment='center', verticalalignment='center', transform=self.ax1.transAxes)

    def update_plot(self):
        self.parse_log_file()
        if plotFig:
            if self.load_steps:  # Check if load_steps array is not empty
                self.plot_data()
                self.fig.canvas.draw()  # Redraw the figure
                plt.pause(10.0)  # Pause to allow plot to refresh
        else:
            current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"Updated: {current_time}, Last load-step: {self.load_step}, Last load-level: {round(self.load_level,1)} / 20",)

def main():
    parser = LogFileParser(log_file)
    
    while True:
        parser.update_plot()
        time.sleep(10)  # Adjust the interval as needed

if __name__ == "__main__":
    main()
