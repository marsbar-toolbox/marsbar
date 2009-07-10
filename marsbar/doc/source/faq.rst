=============
 MarsBaR FAQ
=============

.. _fish:

What's with the fish?
~~~~~~~~~~~~~~~~~~~~~

When MarsBaR first starts, it flashes up a picture of a sardine. The
sardine is a symbol of Marseille, the spiritual home of MarsBaR. To
explain further, here's an `excerpt from France Monthly
<http://www.francemonthly.com/n/1002/index.php#article2>`_ online
magazine, entitled **The Sardine That Blocked the Port Entrance**.


   "We" say, in France (understanding that the "we" excludes the
   people of Marseilles), that the people of Marseilles have a
   tendency to exaggerate their stories. And it is stated, by these
   local people, that one day a sardine (the little fish!) blocked
   the entrance to the port. But this is not said in jest, a slight
   distortion maybe! In 1778, the Viscount of Barras, officer of the
   marine infantry regiment from Pondichery in India was captured by
   the British. Benefiting from special accords for prisoner of war
   exchanges, he embarked the following year on a boat, named the
   "Sartine", which was not armed. To prevent potential attacks upon
   it, the captain would raise certain cartel flags that the enemy
   would recognize. However, the rule was not respected, because on
   May 1st, 10 months after being at sea without incident, a British
   war boat attacked the "Sartine" with two fatal canon volleys. The
   ship finished its trip and ran aground at the entrance to the old
   port. It is therefore not a "sardine" that blocked the port of
   Marseilles but a ship named "La Sartine", on a beautiful spring
   day in 1780!


.. _cant-open:

Why do I get an error "Cant open image file" when estimating a design?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This occurs when the filenames in your SPM or MarsBaR design no
longer point to valid files. For example, when you first estimated
the design, the time series images might have been in a directory
called/now/dead/directory - like this::

  /now/dead/directory/subject1/sess1/image_01.img
  /now/dead/directory/subject1/sess1/image_02.img
  ...
  /now/dead/directory/subject1/sess2/image_01.img
  ...
  /now/dead/directory/subject2/sess1/image_01.img

etc.

Time passed, you reorganized your files, and these images have now
moved to another directory, like this::

  /currently/extant/path/subject1/sess1/image_01.img
  /currently/extant/path/subject1/sess1/image_02.img
  ...
  /currently/extant/path/subject1/sess2/image_01.img
  ...
  /currently/extant/path/subject2/sess1/image_01.img

etc.

When you ask MarsBaR to estimate the original design, it looks for
``/now/dead/directory/subject1/sess1/image_01.img``, but the file does
not exist. To fix this, you will need to change the filenames in the
design to match the new image locations.

You can first check if this is the problem. Click on Design and choose
Check image names in design. You should see an error message in the
matlab console window if the images are not where the design says they
are.

Next, you need to find the correct root path to the images. The root
path is the shared common path for all the image names. In the above
example, the shared common path for the correct image filenames is
``/currently/extant/path``.

To do the fix, you click on Design and choose Change design path to
images. In the SPM input window you will see the current root
directory printed in bold text. In the example above, this would be:
``/now/dead/directory``.

You select ``/currently/extant/path`` using the SPM file selection
window that has just appeared. If all went well, you can check it has
worked; click Design, choose Check image names in design and hope that
you get the message ``All images in design appear to exist`` in the
matlab window.

The same thing from the command line would be::

   D = mardo('/path/to/spm/mat/SPM.mat');
   D = cd_images(D, '/currently/extant/path');
   save_spm(D);

   
.. _percent-signal:

How is the percent signal change calculated?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Good question. Let us imagine that you had an FMRI design with one
event type, which is a flashing checkerboard. There is only one
session of data. The events are all modeled with a haemodynamic
response function (HRF) and the temporal derivative (TD). You run the
MarsBaR model on these data, for an ROI in the visual cortex. Now you
want the percent signal change.

Here's how it goes. You select the event using the MarsBaR percent
signal change interface. MarsBaR does the following:

1. Finds the betas for this event. In this case the relevant betas
   are the first two betas, the beta for the HRF, and the beta for
   the TD.

2. Makes a new regressor for a single event. Remember that the best
   estimate of the signal due to the event is the beta values for
   this event multiplied by the regressors in the design matrix. So,
   to reconstruct the height of a single event of this type, we need
   to multiply the betas that we have calculated in the model by a
   regressor which is like the SPM design matrix regressor in
   scaling, but which is just for a single event. To do this we
   specify the duration of the event we want to estimate the height
   for, and run a single event of this duration back through the SPM
   design matrix machinery, to make the regressor(s) SPM would have
   used for just this single event. In this case we will get an HRF
   regressor and a TD regressor.

3. Next we multiply the betas that we have by the regressors (HRF
   beta * HRF regressor, TD beta * TD regressor), and sum up the two
   resulting time courses, to get the estimated event response for a
   single event of this event type. To get the size of the response,
   for now, we just take the maximum height of the reconstructed
   event. Let's say this is about 0.2 units.

4. We've said 0.2 units, but units of what? SPM scales the mean of all
   the in-brain voxels in the session to be 100 (see this `SPM
   statistics tutorial`_ for more detail on the scaling procedure). So,
   0.2 units means 0.2 percent of the whole brain mean signal (in the
   rather strange SPM sense). The problem with this is, that gray matter
   has a higher signal than the brain average. In fact, if the whole
   brain mean is 100, the gray matter signal tends to be about
   180-200. We want to calculate signal change relative to the baseline
   in this ROI, so we do not want to use the value 100 as the baseline,
   we want to use the actual mean signal in this ROI, which will likely
   be in the range of 180-200. The next step is therefore to get the
   mean signal in the ROI. For this, we simply get the beta for the mean
   column for this session. You remember that SPM removes the mean
   signal within a session by using a session regressor which is just 1s
   in the scans for this session and zeros elsewhere. These columns are
   the last columns in the design matrix. In our case the mean column is
   the third (and last) column, so, to get the session mean, we just
   take the third (and last) beta. By doing this, we've ignored some
   complexities, to do with the mean-centering of the regressors in the
   design matrix, but let's just quietly sweep that under the
   carpet. There, all gone.

5. Let's say our session mean was 192. Now, to get percent signal
   change, we just divide 0.2 by 192. We get roughly 0.001. The last
   step is to multiply by 100 to get percent signal change - which
   gives (roughly) 0.1.

The values you get may be rather small compared to reported values
for - say - signal change for a block of visual stimuation. In fact
you may well get signal change values that are less than 0.1 percent.
Your event may not be comparable to these reports. First, your events
may be short, which will of course give less maximum signal change
than a long block. Second, cognitive events usually give lower signal
change than events affecting primary motor or sensory cortex.

.. _marsbar-batch:

How do I run a MarsBaR analysis in batch mode?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is a tiny example of a batch mode script. It assumes you have a
design which has been estimated in SPM, and has a set of contrasts
specified. The script snippet will work only for later versions of
marsbar-devel.

This example script assumes your design is stored in
``/my/path/SPM.mat`` and you have an ROI stored in
``/my/path/my_roi.mat``::

   spm_name = '/my/path/SPM.mat';
   roi_file = '/my/path/my_roi.mat';
     
   % Make marsbar design object
   D  = mardo(spm_name);
   % Make marsbar ROI object
   R  = maroi(roi_file);
   % Fetch data into marsbar data object
   Y  = get_marsy(R, D, 'mean');
   % Get contrasts from original design
   xCon = get_contrasts(D);
   % Estimate design on ROI data
   E = estimate(D, Y);
   % Put contrasts from original design back into design object
   E = set_contrasts(E, xCon);
   % get design betas
   b = betas(E);
   % get stats and stuff for all contrasts into statistics structure
   marsS = compute_contrasts(E, 1:length(xCon));

See the help for the `compute_contrasts`_ function for details on the
contents of the marsS structure.

.. percent-activated:

How can I extract the percent of activated voxels from an ROI?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is no easy way of doing this using the MarsBaR GUI, but you can
do it using scipts like this one::

   roi_file = 'my_roi.mat';
   t_imgs = strvcat('spmT_0002.img', 'spmT_0003.img');
   thresholds = [3.4 4.6];
   roi_obj = maroi(roi_file);
   y = getdata(roi_obj, t_imgs);
   n_voxels = size(y, 2);
   for i = 1:size(t_imgs, 1)
     pc_above_thresh(i) = sum(y(i,:) > thresholds(i)) / n_voxels * 100;
   end

.. _design-timecourse:

How do I get timecourses from images in an SPM design?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In the GUI, choose Data - Extract ROI data (default). Select your
ROIs and your design (if you had not set it previously). MarsBaR
extracts the data; you can then plot it or save it in various formats
using Data - Export. In script form, this would be something like::

   roi_files = spm_get(Inf,'*roi.mat', 'Select ROI files');
   des_path = spm_get(1, 'SPM.mat', 'Select SPM.mat');
   rois = maroi('load_cell', roi_files); % make maroi ROI objects
   des = mardo(des_path);  % make mardo design object
   mY = get_marsy(rois{:}, des, 'mean'); % extract data into marsy data object
   y  = summary_data(mY);  % get summary time course(s)

.. _raw-timecourse:

I just want to get raw timecourses from some images; how do I do that?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This can be done from the GUI. Select Data - Extract ROI data (full
options). Select the ROIs, say No to use SPM design, Other for type
of images, 1 for number of subjects. Select the images you want to
extract data from, Raw data for scaling, and 0 for grand mean. Now
you can plot the data from the GUI, or save in various formats using
Data - Export data. The script to do this might be::

   roi_files = spm_get(Inf,'*roi.mat', 'Select ROI files');
   P = spm_get(Inf,'*.img','Select images');
   rois = maroi('load_cell', roi_files);  % make maroi ROI objects
   mY = get_marsy(rois{:}, P, 'mean');  % extract data into marsy data object
   y = summary_data(mY); % get summary time course(s)

.. _fmristat:
   
I get errors using the SPM ReML estimation for FMRI designs. Can I try something else?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Why yes, in fact you can. MarsBaR includes the AR modelling from Keith
Worsley's `fmristat program
<http://www.math.mcgill.ca/keith/fmristat>`_, which is a good
alternative to the standard SPM ReML for FMRI. To use this, load your
design in the GUI, then choose Design - Add/Edit filter for SPM
design. Set the high-pass filter as you wish, and then choose "fmristat
AR(n)" for serial autocorrelations. Set the order of the model (AR(1),
AR(2) etc) - 2 is a good choice. Estimate the model in the usual way.

In batch mode this would look like::

   % Make marsbar design object
   D  = mardo(spm_name);
   % Set fmristat AR modelling
   D = autocorr(D, 'fmristat', 2);
   
.. _fir-info:

How is the FIR (or PSTH) calculated?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MarsBaR and SPM use FIR models to calculate the PSTH (peri-stimulus time
histogram). By default, the FIR models have a time bin of one TR. Let us
imagine your TR is one second, as is your FIR time-bin.  You can then
think of the FIR as calculating the best estimate of the signal 0
seconds, 1 seconds, 2 seconds after the event has occurred, and after
adjusting for other effects in the model.

As this is just a very similar approach to averaging, there is no
constraint that the signal should be at zero at 0 seconds. Just for
example, random noise will mean than the average signal at 0 seconds
will not be exactly zero.

For more information on the FIR method used for the PSTH, you might
want to have a look at these papers:

  Ollinger JM, Shulman GL, Corbetta M. Separating processes within a
  trial in event-related functional MRI. Neuroimage. 2001
  Jan;13(1):210-7.

  Dale AM. Optimal experimental design for event-related fMRI. Hum
  Brain Mapp. 1999;8(2-3):109-14.

Russ Poldrack also has a useful page on `FIR modelling`_.

.. _extract-fir:

How do I extract all the FIR timecourses from my design?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can of course do this via the GUI. The most efficient is to do it
with a batch script. You have already run the batch script above up
to ``E = estimate(D, Y);``. Then::

   % Get definitions of all events in model
   [e_specs, e_names] = event_specs(E);
   n_events = size(e_specs, 2);
   % Bin size in seconds for FIR
   bin_size = tr(E);
   % Length of FIR in seconds
   fir_length = 24;
   % Number of FIR time bins to cover length of FIR
   bin_no = fir_length / bin_size;
   % Options - here 'single' FIR model, return estimated
   opts = struct('single', 1, 'percent', 1);
   % Return time courses for all events in fir_tc matrix
   for e_s = 1:n_events
     fir_tc(:, e_s) = event_fitted_fir(E, e_specs(:,e_s), bin_size, ...
   				    bin_no, opts);
   end
   

If your events have the same name across sessions, and you want to
average across the events with the same name::

   % Get compound event types structure
   ets = event_types_named(E);
   n_event_types = length(ets);
   % Bin size in seconds for FIR
   bin_size = tr(E);
   % Length of FIR in seconds
   fir_length = 24;
   % Number of FIR time bins to cover length of FIR
   bin_no = fir_length / bin_size;
   % Options - here 'single' FIR model, return estimated % signal change
   opts = struct('single', 1, 'percent', 1);
   for e_t = 1:n_event_types
      fir_tc(:, e_t) = event_fitted_fir(E, ets(e_t).e_spec, bin_size, ...
         bin_no, opts);
   end

.. _extract-pct:

How do I extract percent signal change from my design using batch?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Maybe something like `this`_::


   % Get definitions of all events in model
   [e_specs, e_names] = event_specs(E);
   n_events = size(e_specs, 2);
   dur = 0;
   % Return percent signal esimate for all events in design
   for e_s = 1:n_events
     pct_ev(e_s) = event_signal(E, e_specs(:,e_s), dur);  
   end

.. _rfx:

How do I do a random effect analysis in MarsBaR?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are two ways to do this.


1. Do your ROI analysis for each subject. From the GUI, or via batch
   mode, extract the "contrast value" for your t contrast of
   interest. Put these values into a matlab matrix, with one value
   per subject (to take the simplest case). You have two ways to go
   from there. Either export this matrix to a spreadsheet or text
   file, and run the statistics using another statistics program, or
   load the SPM random effects design into MarsBaR, import your
   matlab matrix as the data, and run the random effects analysis in
   MarsBaR.

2. Run the full SPM analysis for each subject. Write out the contrast
   image for the contrast of interest. Run the random effects design
   in SPM. Then, import the random effects design into MarsBaR, and
   run it using your ROI. Here you are extracting the (e.g.) mean
   contrast value within the ROI for each subject, and using that as
   your estimate of the effect for that subject.

If you do ordinary least squares (OLS) analyses at the single-subject
level, these two approaches will give you the exact same answer. OLS
is the analysis that does not try to correct for auto-correlation in
the data.

If you did not use OLS, then the first approach is more valid, as in
this case, you have estimated the autocorrelation from the ROI
itself, rather than the whole (activated) brain, which is the default
SPM approach.

OLS at the single subject level is valid (is not biased), but is
likely to be less powerful than the alternative (which is removing
the autocorrelation - "whitening"). In practice the difference
between using and not using OLS is often small.

The first approach also saves you having to run the SPM models at the
single subject level, but you have often done this in any case.

.. _svc:

Should I use MarsBaR ROI analysis, or small volume correction (SVC) in SPM?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Good question - thanks for asking. The two approaches will give
answers to different questions. MarsBaR asks something like "does
area A on average activate more for condition 1 than condition 2",
whereas SVC asks "given I am only looking within the voxels of area
A, are there any voxels in A that I can be confident are more active
in condition 1 than condition 2". Thus, if you have a good idea of
the region you are interested in, and believe that the response
should be relatively homogenous across the region, then the MarsBaR
question is likely to be the closest to the one you want to answer.
However, if you do not have a good idea of the exact definition of
the region you are interested in, and think there may will be
different responses in different parts of the region that you define,
then you might prefer SVC, which can detect peaks of activity even if
the rest of the region is not activated, or even is negative.

Of course, the meaning of the results is slightly different. SVC
allows you to say that some part of your candidate region is active
(allowing for example that most of it could be deactivated). MarsBaR
would likely find no significant change in that situation.

Summary: which you prefer depends on the exact question you want to
answer, which in turn depends on the region definition that you are
using.

.. _smoothed:

Should I use smoothed or unsmoothed images for my MarsBaR analysis?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Of course, you can also think of using smoothed images as using a
smoothed version of your ROI definition. Deciding whether to smooth is a
trade-off between trying to:

1. increase voxel-to-voxel signal to noise, and

2. avoid polluting region signal by signal from nearby structures.

So, if your region definition is a conservative one in the centre of
a large structure that you believe to be homogenous, then you might
opt for image smoothing, on the basis that the risk from nearby
signal is rather small. If your region was well-defined, and
surrounded by other things such as CSF that you really wanted to
avoid, you would probably choose unsmoothed images. The hippocampus
strikes me as a good example of the latter...

.. _uigetfile:

Why can't I select files like SPM designs in the matlab GUI?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are running matlab 7 on Linux, you may have difficulty with
the matlab GUI routines that MarsBaR uses to select files, like SPM
designs and ROI data.

This is caused by a bug in matlab. You may find documentation for this
by searching the Matlab site with the terms "uigetfile linux". It's a
bizarre bug, which causes matlab to appear not to find files when you
click on them in the matlab "uigetfile" interface that MarsBaR uses. If
you are using the default method of running matlab, which uses the fancy
Java desktop, you can get round it using the workaround documented at
the link above, which is to run the following command::

   setappdata(0,'UseNativeSystemDialogs',false)
   
in matlab, before you ever start a file selection dialog, such as those
in MarsBaR. Future versions of MarsBaR will do this automatically. This
fix doesn't work if you are running in non-Java mode - which is what you
get if you start matlab with::

   matlab -nojvmmatlab -nojvm
   

In that case, you will need to either select the file using the
keyboard, rather than the mouse, or type the file name directly into the
file selection box. There are some other odd wrinkles to the behaviour
of the uigetfile interface in matlab 7, which should be fixed in marsbar
version 0.40 and above. For details,search for comments containing
'uigetfile' in `mars_uifile.m
<http://marsbar.svn.sourceforge.net/viewvc/marsbar/trunk/marsbar/mars_uifile.m?view=markup>`_.

.. _novalid:

Why do I get a "No valid data for roi" warning when extracting data?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You might run into a warning like this::

   > Warning: No valid data for roi 1 ...
   
This is almost invariably because you are sampling from SPM results
images, that have NaNs at the edges of the brain. Marsbar uses linear
resampling by default to get the data from the images, so voxels at
the edge of the brain disappear due to resampling with NaN values.
The fix is to change the ROI resampling to nearest neighbour using
something like::

   roi_filename = 'my_roi.mat';
   my_roi = maroi(roi_filename);
   my_roi = spm_hold(my_roi, 0); % set NN resampling
   saveroi(my_roi, roi_filename);
   

and then rerun the data extraction... 


.. _`SPM statistics tutorial`: http://imaging.mrc-cbu.cam.ac.uk/imaging/PrinciplesStatistics
.. _`compute_contrasts`: http://marsbar.sourceforge.net/doc-devel/latest/marsbar/@mardo_99/compute_contrasts.html
.. _`FIR modelling`: http://sourceforge.net/docman/display_doc.php?docid=6217&group_id=13529
.. _`this`: http://marsbar.sourceforge.net/doc-devel/latest/marsbar/@mardo/event_signal.html
